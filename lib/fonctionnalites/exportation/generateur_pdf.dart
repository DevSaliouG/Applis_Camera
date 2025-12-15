import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../../modeles/modele_media.dart';
import '../../core/utils/utils_media.dart';

class GenerateurPDF {
  static Future<String> genererPDF(List<ElementMedia> medias) async {
    final pdf = pw.Document();

    for (var media in medias) {
      if (media.type == 'image') {
        try {
          final imageBytes = await File(media.cheminLocal).readAsBytes();
          final image = pw.MemoryImage(imageBytes);

          pdf.addPage(
            pw.Page(
              pageFormat: PdfPageFormat.a4,
              build: (pw.Context context) {
                return pw.Container(
                  padding: pw.EdgeInsets.all(40),
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          borderRadius: pw.BorderRadius.circular(20),
                          boxShadow: [
                            pw.BoxShadow(
                              color: PdfColors.grey300,
                              blurRadius: 20,
                             // offset: pw.Offset(0, 10),
                            ),
                          ],
                        ),
                        child: pw.ClipRRect(
                          horizontalRadius: 20,
                          verticalRadius: 20,
                          child: pw.Image(image, fit: pw.BoxFit.contain),
                        ),
                      ),
                      pw.SizedBox(height: 30),
                      pw.Text(
                        UtilsMedia.obtenirNomFichier(media.cheminLocal),
                        style: pw.TextStyle(
                          fontSize: 16,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey800,
                        ),
                      ),
                      pw.SizedBox(height: 10),
                      pw.Text(
                        'Date: ${UtilsMedia.formaterDate(media.dateCreation)}',
                        style: pw.TextStyle(
                          fontSize: 12,
                          color: PdfColors.grey600,
                        ),
                      ),
                      if (media.annotations != null && media.annotations!.isNotEmpty)
                        pw.Padding(
                          padding: pw.EdgeInsets.only(top: 20),
                          child: pw.Container(
                            padding: pw.EdgeInsets.all(15),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.grey100,
                              borderRadius: pw.BorderRadius.circular(10),
                            ),
                            child: pw.Text(
                              'Notes: ${media.annotations}',
                              style: pw.TextStyle(
                                fontSize: 12,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              },
            ),
          );
        } catch (e) {
          print('Erreur génération PDF pour ${media.cheminLocal}: $e');
        }
      }
    }

    // Sauvegarder le PDF
    final Directory directory = await getApplicationDocumentsDirectory();
    final String cheminPDF = '${directory.path}/export_${DateTime.now().millisecondsSinceEpoch}.pdf';
    final File fichier = File(cheminPDF);
    await fichier.writeAsBytes(await pdf.save());

    return cheminPDF;
  }
}