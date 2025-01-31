import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym_buddy/utils/helpers.dart' as helpers;
import 'package:integration_test/integration_test.dart';
import 'package:uuid/uuid.dart';

// Import potential activities to the database

void main() async {
  test('Push activities to database', () async {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
    await helpers.firebaseInit(test: true); // set it to false when pushing to the live database
    final FirebaseFirestore db = FirebaseFirestore.instance;
    
    // Now the list of potential activities are given here
    // In the future they are going to be fetched from a file or other sources
    List<String> activities = [
      'Chest',
      'Back',
      'Legs',
      'Cardio',
      'Arms'
    ];

    final actDocRef = db.collection('activities');
    
    const int batchSize = 200; 
    WriteBatch batch = db.batch();
    int count = 0;

    // First delete all documents in activities/
    var snapshots = await actDocRef.get();
    for (var doc in snapshots.docs) {
      count++;
      batch.delete(doc.reference);
      if (count % batchSize == 0) {
        await batch.commit();
        batch = db.batch();
      }
    }
    await batch.commit();

    final uuid = Uuid();
    count = 0;
    batch = db.batch();

    for (final el in activities) {
      count++;
      String actID = uuid.v4();
      final acts = actDocRef.doc(actID);
      final data = {
        'name': el,
      };
      batch.set(acts, data);

      if (count % batchSize == 0) {
        await batch.commit();
        batch = db.batch();
      }
    }

    if (count % batchSize != 0) {
      await batch.commit();
    }
  });  
}
