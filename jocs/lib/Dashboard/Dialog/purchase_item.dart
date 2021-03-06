import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jocs/Dashboard/Controllers/dashboard_controller.dart';

/// Show a form to Add or Update Purchase Item
class PurchaseItem extends StatefulWidget {
  const PurchaseItem({Key? key, required this.previousData, required this.time}) : super(key: key);

  final List<String> previousData;
  final String time;
  @override
  _PurchaseItemState createState() => _PurchaseItemState();
}

class _PurchaseItemState extends State<PurchaseItem> {
  final _formKey = GlobalKey<FormState>();

  final DashboardController _dashboardController =
  Get.find<DashboardController>();

  final TextEditingController orderNoController = TextEditingController();

  final TextEditingController orderNameController = TextEditingController();

  final TextEditingController descriptionController = TextEditingController();

  final TextEditingController deliveryController = TextEditingController();

  final TextEditingController statusController = TextEditingController();

  final TextEditingController commentsController = TextEditingController();

  bool updateData = false;

  @override
  void initState() {
    print(widget.previousData);
    if (widget.previousData.isNotEmpty){
      orderNoController.text = widget.previousData[0];
      orderNameController.text = widget.previousData[1];
      descriptionController.text = widget.previousData[2];
      deliveryController.text = widget.previousData[3];
      statusController.text = widget.previousData[4];
      commentsController.text = widget.previousData[5];
      updateData = true;
    }
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 350,
              child: Material(
                child: TextFormField(
                  controller: orderNoController,
                  decoration: const InputDecoration(
                    labelText: 'Order No.',
                    hintText: '1',
                  ),
                  validator: (value) {
                    print(value);
                    if (value == null || value.isEmpty) {
                      return 'Order No.?';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 350,
              child: Material(
                child: TextFormField(
                  controller: orderNameController,
                  decoration: const InputDecoration(
                    labelText: 'Order Name',
                    hintText: 'Order Name',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Order Name?';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 350,
              child: Material(
                child: TextFormField(
                  controller: descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    hintText: 'XYZ',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Description?';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
              width: 350,
              child: Material(
                child: TextFormField(
                  controller: deliveryController,
                  decoration: const InputDecoration(
                    labelText: 'Expected Delivery',
                    hintText: '12/09/22',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Expected Delivery?';
                    }
                    return null;
                  },
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                width: 350,
                child: Material(
                  child: TextFormField(
                    controller: statusController,
                    decoration: const InputDecoration(
                        labelText: 'Status', hintText: 'Mr. XYZ'),
                  ),
                )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SizedBox(
                width: 350,
                child: Material(
                  child: TextFormField(
                    controller: commentsController,
                    decoration: const InputDecoration(
                        labelText: 'Comments', hintText: 'Add Your Comments'),
                  ),
                )),
          ),
          Container(
            margin: const EdgeInsets.only(top: 32.0),
            child: TextButton(

              onPressed: () {
                if (_formKey.currentState!.validate()){
                  if (updateData) {
                    print ("Update Data");
                    _dashboardController.updateTableData(
                      "purchase",
                      widget.time,
                      {
                        'order_no': orderNoController.text, // John Doe
                        'order_name': orderNameController.text, // Stokes and Sons
                        'description': descriptionController.text, // 42
                        'expected_delivery': deliveryController.text,
                        'status': statusController.text,
                        'comments': commentsController.text,
                      },
                    );
                  } else {
                    _dashboardController.addDataToFirebase({
                      'order_no': orderNoController.text, // John Doe
                      'order_name': orderNameController.text, // Stokes and Sons
                      'description': descriptionController.text, // 42
                      'expected_delivery': deliveryController.text,
                      'status': statusController.text,
                      'comments': commentsController.text,
                      'time' : DateTime.now().toUtc().millisecondsSinceEpoch.toString()
                    }, "purchase", "purchaseCount", _dashboardController.metadata.value.purchaseCount);
                  }

                  setState(() {
                    orderNoController.clear();
                    orderNameController.clear();
                    descriptionController.clear();
                    deliveryController.clear();
                    statusController.clear();
                    commentsController.clear();
                    commentsController.clear();
                  });
                  Get.back();
                }

              },
              child: widget.time.isEmpty ? Text(
                "Add Purchase Item",
                style: Get.textTheme.bodyText1,
              ) : Text(
                "Update Purchase Item",
                style: Get.textTheme.bodyText1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
