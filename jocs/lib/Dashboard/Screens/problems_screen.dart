import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jocs/Dashboard/Controllers/dashboard_controller.dart';

class ProblemsScreen extends StatelessWidget {
  ProblemsScreen({Key? key}) : super(key: key);

  final DashboardController _dashboardController =
  Get.find<DashboardController>();
  Map<String,  String> customFilter = <String, String>{};

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      controller: ScrollController(),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                child: Obx(
                      () => Theme(
                    data: Get.theme.copyWith(
                        textTheme: TextTheme(
                            caption: TextStyle(
                                color: Get.theme.appBarTheme
                                    .backgroundColor))),
                    child: PaginatedDataTable(
                      columns: [
                        const DataColumn(label: Text("Issued By")),
                        const DataColumn(label: Text("Topic")),
                        DataColumn(
                          label: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.theme.appBarTheme.backgroundColor, //background color of  //border of dropdown button
                              borderRadius: const BorderRadius.all(Radius.circular(12)), //border raiuds of dropdown button
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Theme(
                                data: context.theme.copyWith(canvasColor: context.theme.appBarTheme.backgroundColor),
                                child: DropdownButton(
                                  iconEnabledColor: context.theme.appBarTheme.foregroundColor,
                                  style: context.textTheme.bodyText1,
                                  value: "Status",
                                  items: <String>["Status", "OPEN", "PENDING", "RESOLVED", "CLOSED"].map((value){
                                    return DropdownMenuItem(
                                      child: Text(value, textAlign: TextAlign.right,),
                                      value: value,
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue){
                                    if (newValue != null){
                                      customFilter["status"] = newValue;
                                      _dashboardController.getProblemsData(customFilter:customFilter);
                                    }
                                  },
                                  isExpanded: false,
                                  underline: Container(),

                                ),
                              ),
                            ),
                          ),
                        ),
                        DataColumn(
                          label: DecoratedBox(
                            decoration: BoxDecoration(
                              color: context.theme.appBarTheme.backgroundColor, //background color of  //border of dropdown button
                              borderRadius: const BorderRadius.all(Radius.circular(12)), //border raiuds of dropdown button
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                              child: Theme(
                                data: context.theme.copyWith(canvasColor: context.theme.appBarTheme.backgroundColor),
                                child: DropdownButton(
                                  iconEnabledColor: context.theme.appBarTheme.foregroundColor,
                                  style: context.textTheme.bodyText1,
                                  value: "Priority",
                                  items: <String>["Priority", "LOW", "MEDIUM", "HIGH", "URGENT"].map((value){
                                    return DropdownMenuItem(
                                      child: Text(value, textAlign: TextAlign.right,),
                                      value: value,
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue){
                                    if (newValue != null){
                                      customFilter["priority"] = newValue;
                                      _dashboardController.getProblemsData(customFilter:customFilter);
                                    }
                                  },
                                  isExpanded: false,
                                  underline: Container(),

                                ),
                              ),
                            ),
                          ),
                        ),
                        const DataColumn(label: Text("Assigned To")),
                        const DataColumn(label: Text("Department")),
                      ],
                      source: _dashboardController
                          .problemAdapter.value.dataTableSource.value,
                      arrowHeadColor:
                      Get.theme.appBarTheme.backgroundColor,
                      onPageChanged: (int? index) {
                        if (index != null) {
                          if (((index+1)/10).ceil() > _dashboardController.problemAdapter.value
                              .currentPaginatedPage){
                            _dashboardController.problemAdapter.value
                                .getNextPage(_dashboardController
                                .firebaseController, customFilter);
                          }
                          _dashboardController.problemAdapter.value
                              .currentPaginatedPage = ((index+1)/10).ceil();

                        }

                      },
                    ),
                  ),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}

// class CustomDataTableSource extends DataTableSource {
//   List<DataRow>? data = <DataRow>[];
//
//   CustomDataTableSource([this.data]);
//
//   @override
//   DataRow? getRow(int index) {
//     final DashboardController _dashboardController =
//     Get.find<DashboardController>();
//     try {
//       return data == null ? null : data![index];
//     } on RangeError catch (e) {
//       null;
//     }
//   }
//
//   @override
//   bool get isRowCountApproximate => false;
//
//   @override
//   int get rowCount {
//     final DashboardController _dashboardController =
//     Get.find<DashboardController>();
//     return _dashboardController.problemAdapter.value.lastId.value - 1;
//   }
//
//   @override
//   int get selectedRowCount => 0;
// }
//
