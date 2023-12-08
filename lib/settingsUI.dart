import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

TextEditingController ip = new TextEditingController();
TextEditingController port = new TextEditingController();

class SettingsUI extends StatefulWidget {
  const SettingsUI({super.key});

  @override
  State<SettingsUI> createState() => _SettingsUIState();
}

class _SettingsUIState extends State<SettingsUI> {
  @override
  void initState() {
    super.initState();
    _checkIp();
  }

  _checkIp() async {
    var box = await Hive.openBox('ipBox');
    if (box.get("ip") == null || box.get('port') == null) {
      ip.text = '192.168.0.119';
      port.text = '5000';
    } else {
      ip.text = box.get("ip");
      port.text = box.get("port");
    }
    setState(() {});
  }

  _updateIp() async {
    if (ip.text.isNotEmpty && port.text.isNotEmpty) {
      var box = await Hive.openBox('ipBox');
      await box.put("ip", ip.text);
      await box.put("port", port.text);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.green.shade600,
          content: Text(
            'Ip and Port updated Successfully',
            style: TextStyle(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please Enter IP and Port')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: ip,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'IP Address',
                ),
                onChanged: (value) {
                  // setState(() {
                  //   baseUrl = "http://${ip.text}:${port.text}";
                  // });
                },
              ),
              SizedBox(
                height: 10,
              ),
              TextField(
                controller: port,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Port',
                ),
                onChanged: (value) {
                  // setState(() {
                  //   baseUrl = "http://${ip.text}:${port.text}";
                  // });
                },
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _updateIp();
        },
        elevation: 0,
        icon: Icon(Icons.file_upload_outlined),
        label: Text("Update IP"),
      ),
    );
  }
}
