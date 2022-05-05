import 'dart:io';

import 'package:aramark_excel/logic/logic.dart';
import 'package:aramark_excel/models/entry.dart';
import 'package:aramark_excel/ui/new_input.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
// import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:share_plus/share_plus.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> scanBarcodeNormal() async {
    String? barcodeScanRes;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      // barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
      //     '#ff6666', 'Cancel', true, ScanMode.BARCODE);
      barcodeScanRes = "111";
    } catch (err) {
      // print(err);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error al leer el código!")));
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    if (barcodeScanRes != null && barcodeScanRes != "-1") {
      showDialog(
          context: context,
          builder: (ctx) => NewInput(
                barcodeScanRes: barcodeScanRes!,
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          Padding(
              padding: const EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text("Are you sure"),
                      content:
                          const Text("you want to delete the all elements?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("No"),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              Box<Entry> box = Hive.box<Entry>('entries');
                              box.clear();
                            });
                            Navigator.of(ctx).pop();
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
                  );
                },
                child: const Icon(Icons.delete),
              ))
        ],
      ),
      body: Stack(
        children: [
          ValueListenableBuilder<Box<Entry>>(
            valueListenable: Hive.box<Entry>('entries').listenable(),
            builder: (context, box, widget) {
              if (box.values.isEmpty) {
                return const Center(
                  child: Text("No hay datos"),
                );
              } else {
                return SingleChildScrollView(
                    child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 25, horizontal: 20),
                  child: Column(children: [
                    for (Entry entry in box.values.toList())
                      GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (ctx) => NewInput(
                                    barcodeScanRes: entry.code,
                                    entry: entry,
                                  ));
                        },
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                      "Code: ${entry.code}, Value: ${entry.value}"),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (ctx) => AlertDialog(
                                          title: const Text("Are you sure"),
                                          content: Text(
                                              "Delete the element with code: ${entry.code}?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text("No"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  box.delete(entry.code);
                                                });
                                                Navigator.of(ctx).pop();
                                              },
                                              child: const Text("Yes"),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                    child: const Icon(Icons.delete))
                              ],
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(
                      height: 60,
                    )
                  ]),
                ));
              }
            },
          ),
          if (Hive.box<Entry>('entries').values.isNotEmpty)
            Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: ElevatedButton(
                    onPressed: () async {
                      if (Hive.box<Entry>('entries').values.isNotEmpty) {
                        var excel = Excel.createExcel();
                        excel = generate('Sheet1', excel,
                            Hive.box<Entry>('entries').values.toList());
                        DateTime now = DateTime.now();
                        if (excel.encode() != null) {
                          final String tempPath =
                              (await getTemporaryDirectory()).path;
                          final fileName =
                              "$tempPath/aramark-${now.toString()}.xlsx";
                          File file = File(fileName);
                          file.writeAsBytesSync(excel.encode()!);
                          Share.shareFiles([fileName]);
                        }
                      } else {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(const SnackBar(
                          content: Text('No hay datos'),
                        ));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 35, vertical: 15),
                        elevation: 1,
                        primary: Colors.white,
                        shape: RoundedRectangleBorder(
                          side: const BorderSide(color: Colors.blue, width: 2),
                          borderRadius: BorderRadius.circular(30),
                        )),
                    child: const Text(
                      "Excel",
                      style: TextStyle(
                          color: Colors.blue, fontWeight: FontWeight.bold),
                    ),
                  ),
                ))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: scanBarcodeNormal,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
