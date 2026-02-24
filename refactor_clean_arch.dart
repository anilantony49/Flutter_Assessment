// import 'dart:io';

// void main() async {
//   final libDir = Directory('lib');
  
//   if (!await libDir.exists()) {
//     print('lib directory not found');
//     return;
//   }

//   // Define new paths
//   final coreDir = Directory('lib/core');
//   final newUtilsDir = Directory('lib/core/utils');
//   final newWidgetsDir = Directory('lib/core/widgets');
  
//   // Create clean architecture directories
//   final dirsToCreate = [
//     'lib/core',
//     'lib/data/datasources',
//     'lib/data/models',
//     'lib/data/repositories',
//     'lib/domain/entities',
//     'lib/domain/repositories',
//     'lib/domain/usecases',
//   ];

//   for (final dirPath in dirsToCreate) {
//     await Directory(dirPath).create(recursive: true);
//   }

//   // Move domain/repository to domain/repositories (if it exists)
//   final oldRepoDir = Directory('lib/domain/repository');
//   if (await oldRepoDir.exists()) {
//     try {
//       await oldRepoDir.rename('lib/domain/repositories');
//     } catch (e) {
//       // If rename fails (e.g. crossing devices), move files
//       await for (final file in oldRepoDir.list(recursive: true)) {
//         if (file is File) {
//           final newPath = file.path.replaceAll('domain${Platform.pathSeparator}repository', 'domain${Platform.pathSeparator}repositories');
//           await File(newPath).create(recursive: true);
//           await file.copy(newPath);
//           await file.delete();
//         }
//       }
//       await oldRepoDir.delete(recursive: true);
//     }
//   }

//   // Move utils to core/utils
//   final oldUtilsDir = Directory('lib/utils');
//   if (await oldUtilsDir.exists()) {
//     try {
//       await oldUtilsDir.rename(newUtilsDir.path);
//     } catch (e) {
//       await for (final file in oldUtilsDir.list(recursive: true)) {
//         if (file is File) {
//           final newPath = file.path.replaceAll('lib${Platform.pathSeparator}utils', 'lib${Platform.pathSeparator}core${Platform.pathSeparator}utils');
//           await File(newPath).create(recursive: true);
//           await file.copy(newPath);
//           await file.delete();
//         }
//       }
//       await oldUtilsDir.delete(recursive: true);
//     }
//   }

//   // Move widgets to core/widgets
//   final oldWidgetsDir = Directory('lib/widgets');
//   if (await oldWidgetsDir.exists()) {
//     try {
//       await oldWidgetsDir.rename(newWidgetsDir.path);
//     } catch (e) {
//       await for (final file in oldWidgetsDir.list(recursive: true)) {
//         if (file is File) {
//           final newPath = file.path.replaceAll('lib${Platform.pathSeparator}widgets', 'lib${Platform.pathSeparator}core${Platform.pathSeparator}widgets');
//           await File(newPath).create(recursive: true);
//           await file.copy(newPath);
//           await file.delete();
//         }
//       }
//       await oldWidgetsDir.delete(recursive: true);
//     }
//   }

//   // Update imports in all dart files
//   await for (final entity in libDir.list(recursive: true)) {
//     if (entity is File && entity.path.endsWith('.dart')) {
//       String content = await entity.readAsString();
//       bool modified = false;

//       if (content.contains('package:flutter_assesment/utils/')) {
//         content = content.replaceAll('package:flutter_assesment/utils/', 'package:flutter_assesment/core/utils/');
//         modified = true;
//       }
      
//       if (content.contains('package:flutter_assesment/widgets/')) {
//         content = content.replaceAll('package:flutter_assesment/widgets/', 'package:flutter_assesment/core/widgets/');
//         modified = true;
//       }

//       if (content.contains('package:flutter_assesment/domain/repository/')) {
//         content = content.replaceAll('package:flutter_assesment/domain/repository/', 'package:flutter_assesment/domain/repositories/');
//         modified = true;
//       }

//       if (modified) {
//         await entity.writeAsString(content);
//         print('Updated imports in ${entity.path}');
//       }
//     }
//   }

//   print('Clean architecture restructuring complete!');
// }
