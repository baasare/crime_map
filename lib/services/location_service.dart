import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_map/models/location_model.dart';
import 'package:crime_map/utils/constants.dart';

class LocationService {
  final fireBaseFirestoreRef = FirebaseFirestore.instance;

  static Future<bool> checkExist(String address) async {
    bool exist;
    try {
      await FirebaseFirestore.instance
          .doc(RealtimeDatabaseKeys.locations + "/" + address)
          .get()
          .then((doc) {
        exist = doc.exists;
      });
      return exist;
    } catch (e) {
      throw e;
    }
  }

  insertLocation(LocationModel location) async {
    try {
      await FirebaseFirestore.instance
          .doc(RealtimeDatabaseKeys.locations + "/" + location.address)
          .get()
          .then((doc) {
        if (doc.exists) {
          LocationModel currentLocation = LocationModel.fromJson(doc.data());
          location.reportNumber = currentLocation.reportNumber + 1;
          location.crimeImages.addAll(currentLocation.crimeImages);
        }

        print("IMAGES LENGTH: ${location.crimeImages.length}");

        fireBaseFirestoreRef
            .collection(RealtimeDatabaseKeys.locations)
            .doc(location.address)
            .set(location.toJson(), SetOptions(merge: true))
            .then((_) {
          print('location added successfully');
        });
      });
    } catch (e) {
      throw e;
    }
  }
}
