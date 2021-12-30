import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:jocs/Theme/custom_theme.dart' hide Colors;

class DashboardController extends GetxController {
  var menuItemStyle = Get.theme.textTheme.headline5;
  var submenuItemStyle = Get.theme.textTheme.headline6;
  var submenuItemStyle2 = Get.theme.textTheme.caption;
  var iconColor = Get.theme.iconTheme.color;
  var tileColor = Get.theme.appBarTheme.backgroundColor;
  late final List<Widget> menuItemWidgets;
  bool mobileDisplay = false;

  DashboardController() {
    body.value = Stack(children: const [DashboardGeneral()]);
  }

  Rx<Widget> body = Stack(
    children: [],
  ).obs;

  RxBool showMenu = false.obs;
  RxBool showMenuForBigScreen = false.obs;
  RxBool showPanel = false.obs;
  Rx<Widget> menuIcon = const Icon(Icons.menu).obs;

  changeBody(bool mobile) {
    mobileDisplay = mobile;
    if (mobile) {
      body.value = Stack(children: const [DashboardMobile()]);
    } else {
      body.value = Stack(children: const [DashboardGeneral()]);
    }
  }
}

class DashboardGeneral extends StatefulWidget {
  const DashboardGeneral({Key? key}) : super(key: key);

  @override
  _DashboardGeneralState createState() => _DashboardGeneralState();
}

class _DashboardGeneralState extends State<DashboardGeneral> {
  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        children: [
          Obx(
            () => Container(
                width: _dashboardController.showPanel.value ? 100 : 300,
                color: _dashboardController.tileColor,
                child: NavItems()),
          ),
          //Obx(() =>
          Expanded(
              child: Container(
                  color: _dashboardController.iconColor,
                  child: Column(children: [Text("He")]))),
          //)
        ],
      )
    ]);
  }
}

class DashboardMobile extends StatefulWidget {
  const DashboardMobile({Key? key}) : super(key: key);

  @override
  _DashboardMobileState createState() => _DashboardMobileState();
}

class _DashboardMobileState extends State<DashboardMobile> {
  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Row(
        children: [
          Expanded(
              flex: 10,
              child: Container(
                  color: Colors.blueAccent,
                  child: Column(children: [Text("He")])))
        ],
      ),
      Obx(() => _dashboardController.showMenu.value
          ? Row(children: [
              Container(
                  width: MediaQuery.of(context).size.width,
                  color: _dashboardController.tileColor,
                  child: NavItems()
              )
            ])
          : const SizedBox(
              width: 0,
              height: 0,
            )),
      Obx(
        () => IconButton(
            onPressed: () {
              _dashboardController.showMenu.value =
                  !_dashboardController.showMenu.value;
              _dashboardController.menuIcon.value =
                  _dashboardController.showMenu.value
                      ? const Icon(Icons.clear)
                      : const Icon(Icons.menu);
            },
            icon: _dashboardController.menuIcon.value),
      ),
    ]);
  }
}

class NavItems extends StatelessWidget {
  NavItems({Key? key}) : super(key: key);

  final DashboardController _dashboardController =
      Get.find<DashboardController>();

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      _dashboardController.mobileDisplay? Container(height: 50, color: _dashboardController.tileColor):Container(
          decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal:
                      BorderSide(color: _dashboardController.iconColor!))),
          child: Obx(
            () => Material(
              child: _dashboardController.showPanel.value
                  ? Container(
                      color: _dashboardController.tileColor,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_forward_ios_outlined),
                        color: _dashboardController.iconColor,
                        onPressed: () {
                          _dashboardController.showPanel.value = false;
                        },
                      ))
                  : ListTile(
                      tileColor: _dashboardController.tileColor,
                      hoverColor: ThemeColors.hoverColor,
                      onTap: () {
                        _dashboardController.showPanel.value = true;
                      },
                      trailing: Icon(Icons.arrow_back_ios_outlined,
                          color: _dashboardController.iconColor),
                      title: Text("HIDE PANEL",
                          style: _dashboardController.menuItemStyle),
                    ),
            ),
          )),
      Container(
          decoration: BoxDecoration(
              border: Border.symmetric(
                  horizontal:
                      BorderSide(color: _dashboardController.iconColor!))),
          child: Obx(
            () => Material(
                child: _dashboardController.showPanel.value
                    ? Container(
                        color: _dashboardController.tileColor,
                        child: IconButton(
                          icon: const Icon(Icons.dashboard),
                          color: _dashboardController.iconColor,
                          onPressed: () {
                            _dashboardController.showPanel.value = false;
                          },
                        ))
                    : ListTile(
                        tileColor: _dashboardController.tileColor,
                        hoverColor: ThemeColors.hoverColor,
                        onTap: () {},
                        leading: Icon(Icons.dashboard,
                            color: _dashboardController.iconColor),
                        title: Text("DASHBOARD",
                            style: _dashboardController.menuItemStyle),
                      )),
          )),
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: _dashboardController.iconColor!))),
        child: Obx(
          () => Material(
              child: _dashboardController.showPanel.value
                  ? Container(
                      color: _dashboardController.tileColor,
                      child: IconButton(
                        icon: const Icon(Icons.all_inbox_sharp),
                        color: _dashboardController.iconColor,
                        onPressed: () {
                          _dashboardController.showPanel.value = false;
                        },
                      ))
                  : ListTile(
                      tileColor: _dashboardController.tileColor,
                      hoverColor: ThemeColors.hoverColor,
                      onTap: () {},
                      leading: Icon(Icons.all_inbox_sharp,
                          color: _dashboardController.iconColor),
                      title: Text("TICKETS",
                          style: _dashboardController.menuItemStyle),
                    )),
        ),
      ),
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: _dashboardController.iconColor!))),
        child: Obx(
          () => Material(
              child: _dashboardController.showPanel.value
                  ? Container(
                      color: _dashboardController.tileColor,
                      child: IconButton(
                        icon: const Icon(Icons.clear),
                        color: _dashboardController.iconColor,
                        onPressed: () {
                          _dashboardController.showPanel.value = false;
                        },
                      ))
                  : ListTile(
                      tileColor: _dashboardController.tileColor,
                      hoverColor: ThemeColors.hoverColor,
                      onTap: () {},
                      leading: Icon(Icons.clear,
                          color: _dashboardController.iconColor),
                      title: Text("PROBLEMS",
                          style: _dashboardController.menuItemStyle),
                    )),
        ),
      ),
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: _dashboardController.iconColor!))),
        child: ExpansionTile(
          tilePadding:
              const EdgeInsets.only(left: 0, right: 8, top: 0, bottom: 0),
          iconColor: _dashboardController.iconColor,
          collapsedIconColor: _dashboardController.iconColor,
          backgroundColor: _dashboardController.tileColor,
          title: Obx(() => Material(
              child: _dashboardController.showPanel.value
                  ? Container(
                      color: _dashboardController.tileColor,
                      child: IconButton(
                        icon: const Icon(Icons.featured_play_list),
                        color: _dashboardController.iconColor,
                        onPressed: () {
                          _dashboardController.showPanel.value = false;
                        },
                      ))
                  : ListTile(
                      tileColor: _dashboardController.tileColor,
                      hoverColor: ThemeColors.hoverColor,
                      onTap: () {},
                      leading: Icon(Icons.featured_play_list,
                          color: _dashboardController.iconColor),
                      title: Text("ASSETS",
                          style: _dashboardController.menuItemStyle),
                    ))),
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Obx(()=>Text(
                          "INVENTORY",
                          style: _dashboardController.showPanel.value?_dashboardController.submenuItemStyle2:_dashboardController.submenuItemStyle,
                          textAlign: TextAlign.left,
                        ),
                      ),
                    )),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextButton(
                    onPressed: () {},
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "PURCHASE ORDER",
                        style: _dashboardController.showPanel.value?_dashboardController.submenuItemStyle2:_dashboardController.submenuItemStyle,
                        textAlign: TextAlign.left,
                      ),
                    )),
              ],
            )
          ],
        ),
      ),
      Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: _dashboardController.iconColor!))),
          child: Obx(
            () => Material(
                child: _dashboardController.showPanel.value
                    ? Container(
                        color: _dashboardController.tileColor,
                        child: IconButton(
                          icon: const Icon(Icons.message),
                          color: _dashboardController.iconColor,
                          onPressed: () {
                            _dashboardController.showPanel.value = false;
                          },
                        ))
                    : ListTile(
                        tileColor: _dashboardController.tileColor,
                        hoverColor: ThemeColors.hoverColor,
                        onTap: () {},
                        leading: Icon(Icons.message,
                            color: _dashboardController.iconColor),
                        title: Text("CHAT",
                            style: _dashboardController.menuItemStyle),
                      )),
          )),
      Container(
          decoration: BoxDecoration(
              border: Border(
                  bottom: BorderSide(color: _dashboardController.iconColor!))),
          child: Obx(
            () => Material(
                child: _dashboardController.showPanel.value
                    ? Container(
                        color: _dashboardController.tileColor,
                        child: IconButton(
                          icon: const Icon(Icons.attach_file),
                          color: _dashboardController.iconColor,
                          onPressed: () {
                            _dashboardController.showPanel.value = false;
                          },
                        ))
                    : ListTile(
                        tileColor: _dashboardController.tileColor,
                        hoverColor: ThemeColors.hoverColor,
                        onTap: () {},
                        leading: Icon(Icons.attach_file,
                            color: _dashboardController.iconColor),
                        title: Text("EXTERNAL KBS",
                            style: _dashboardController.menuItemStyle),
                      )),
          )),
      Container(
        decoration: BoxDecoration(
            border: Border(
                bottom: BorderSide(color: _dashboardController.iconColor!))),
        child: Obx(
          () => Material(
            child: _dashboardController.showPanel.value
                ? Container(
                    color: _dashboardController.tileColor,
                    child: IconButton(
                      icon: const Icon(Icons.settings),
                      color: _dashboardController.iconColor,
                      onPressed: () {
                        _dashboardController.showPanel.value = false;
                      },
                    ))
                : ListTile(
                    tileColor: _dashboardController.tileColor,
                    hoverColor: ThemeColors.hoverColor,
                    onTap: () {},
                    leading: Icon(Icons.settings,
                        color: _dashboardController.iconColor),
                    title: Text("SETTINGS",
                        style: _dashboardController.menuItemStyle),
                  ),
          ),
        ),
      ),
      const Padding(
        padding: EdgeInsets.only(top: 32.0),
        child: ListTile(
          title: Center(
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              child: ClipOval(
                child: Image(
                    image: AssetImage('images/avatar.png'),
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
        ),
      )
    ]);
  }
}
