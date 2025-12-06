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
        final image = pw.MemoryImage(File(media.cheminLocal).readAsBytesSync());

        pdf.addPage(
          pw.Page(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return pw.Column(
                children: [
                  pw.Image(image),
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Date: ${UtilsMedia.formaterDate(media.dateCreation)}',
                    style: const pw.TextStyle(fontSize: 12),
                  ),
                  if (media.annotations != null && media.annotations!.isNotEmpty)
                    pw.Text(
                      'Annotations: ${media.annotations}',
                      style: const pw.TextStyle(fontSize: 12),
                    ),
                ],
              );
            },
          ),
        );
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