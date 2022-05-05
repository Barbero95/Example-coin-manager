import 'package:aramark_excel/models/entry.dart';
import 'package:excel/excel.dart';

generate(String fileName, Excel excel, List<Entry> elements) {
  Sheet sheetObject = excel[fileName];

  CellStyle cellDefaultStyle = CellStyle(
      fontFamily: getFontFamily(FontFamily.Calibri),
      horizontalAlign: HorizontalAlign.Center);
  //cellStyle.underline = Underline.Single;

  CellStyle cellTitleStyle = CellStyle(
      backgroundColorHex: "#E5E8E8",
      fontFamily: getFontFamily(FontFamily.Calibri),
      bold: true,
      horizontalAlign: HorizontalAlign.Center);
  //cellTitleStyle.underline = Underline.Double;

  sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
    ..cellStyle = cellTitleStyle
    ..value = "CODE";
  sheetObject.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
    ..cellStyle = cellTitleStyle
    ..value = "MONEY";

  int currentRow = 1;
  for (Entry element in elements) {
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: currentRow))
      ..cellStyle = cellDefaultStyle
      ..value = element.code;
    sheetObject
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: currentRow))
      ..cellStyle = cellDefaultStyle
      ..value = element.value;
    currentRow++;
  }
  return excel;
}
