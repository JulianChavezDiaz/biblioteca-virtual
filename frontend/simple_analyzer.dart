import 'dart:io';

void main() async {
  print('🔍 Analizando archivos del proyecto...');
  
  final libDir = Directory('lib');
  final allFiles = <String>[];
  final importedFiles = <String>{};
  
  // Encontrar todos los archivos .dart
  await for (final entity in libDir.list(recursive: true)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      allFiles.add(entity.path);
    }
  }
  
  print('📁 Total archivos encontrados: ${allFiles.length}');
  
  // Analizar imports
  for (final filePath in allFiles) {
    try {
      final content = await File(filePath).readAsString();
      final lines = content.split('\n');
      
      for (final line in lines) {
        if (line.trim().startsWith('import ')) {
          // Buscar imports relativos
          if (line.contains('../') || line.contains('./')) {
            final fileName = line.split('/').last.replaceAll("';", '').replaceAll('";', '');
            if (fileName.endsWith('.dart')) {
              importedFiles.add(fileName);
            }
          }
          // Buscar imports por nombre de archivo
          for (final file in allFiles) {
            final fileName = file.split('\\').last.split('/').last;
            if (line.contains(fileName.replaceAll('.dart', ''))) {
              importedFiles.add(fileName);
            }
          }
        }
      }
    } catch (e) {
      print('Error leyendo $filePath: $e');
    }
  }
  
  // Generar reporte
  print('\n📊 REPORTE DE ARCHIVOS');
  print('=' * 50);
  
  final unusedFiles = <String>[];
  for (final filePath in allFiles) {
    final fileName = filePath.split('\\').last.split('/').last;
    if (!importedFiles.contains(fileName) && fileName != 'main.dart') {
      unusedFiles.add(fileName);
    }
  }
  
  print('🚫 ARCHIVOS POTENCIALMENTE NO UTILIZADOS (${unusedFiles.length}):');
  for (final file in unusedFiles) {
    print('   - $file');
  }
  
  print('\n✅ ARCHIVOS UTILIZADOS: ${importedFiles.length}');
  print('📁 TOTAL ARCHIVOS: ${allFiles.length}');
  print('🗑️  POSIBLES A ELIMINAR: ${unusedFiles.length}');
  
  if (unusedFiles.isNotEmpty) {
    print('\n💡 RECOMENDACIÓN:');
    print('   Revisar estos archivos antes de eliminar:');
    for (final file in unusedFiles.take(5)) {
      print('   - $file');
    }
  }
}