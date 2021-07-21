import 'dart:async';
import 'dart:io';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crime_map/models/location_model.dart';
import 'package:crime_map/services/location_service.dart';
import 'package:crime_map/utils/app_config.dart';
import 'package:crime_map/utils/colors.dart';
import 'package:crime_map/utils/constants.dart';
import 'package:crime_map/utils/utils.dart';
import 'package:crime_map/widgets/custom_logout_alert.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:sliding_up_panel/sliding_up_panel.dart';
import 'package:transparent_image/transparent_image.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  Completer<GoogleMapController> _controller = Completer();

  PanelController panelController = PanelController();
  final crimeLocationBarController = TextEditingController();
  GoogleMapController _mapController;
  FocusNode _focus = new FocusNode();

  LocationService locationService = LocationService();
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fireBaseFirestoreRef = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _saving = false;

  BitmapDescriptor currentUserIcon;

  Set<Marker> _markers = {};

  MapType _currentMapType = MapType.normal;

  static const LatLng _center = const LatLng(8.397233, -1.215936);
  LatLng _currentPosition = _center;

  static final CameraPosition _initialCameraPosition = CameraPosition(
    target: _center,
    zoom: 15,
  );

  static double fabHeightClosed = 150.0;
  double fabHeight = fabHeightClosed;

  LatLng _crimePosition;
  String _crimeAddress = "";

  final picker = ImagePicker();
  List<File> selectedImages = [];
  List<String> crimeImagesUrls = [];

  @override
  void initState() {
    getBytesFromAsset('assets/images/userLocationMarker.png', 140)
        .then((onValue) {
      currentUserIcon = BitmapDescriptor.fromBytes(onValue);
    });

    _focus.addListener(_onFocusChange);
    super.initState();
  }

  @override
  void dispose() {
    crimeLocationBarController.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    panelController.open();
  }

  void getCurrentLocation() async {
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    ).then((Position position) async {
      Marker marker = Marker(
        markerId: MarkerId("my_current_location"),
        position: LatLng(position.latitude, position.longitude),
        icon: currentUserIcon,
        rotation: position.heading,
      );

      setState(() {
        _markers.add(marker);
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      updateMapView(LatLng(position.latitude, position.longitude));
    });
  }

  Future getImage(BuildContext context, ImageSource source) async {
    final chosenImage = await picker.pickImage(
      source: source,
      preferredCameraDevice: CameraDevice.front,
    );

    setState(() async {
      if (selectedImages.length <= 4) {
        selectedImages.add(File(chosenImage.path));

        final String fileName = path.basename(chosenImage.path);

        TaskSnapshot taskSnapshot = await storage.ref(fileName).putFile(
              File(chosenImage.path),
              SettableMetadata(
                customMetadata: {
                  'uploaded_by': _auth.currentUser.displayName,
                },
              ),
            );

        taskSnapshot.ref.getDownloadURL().then((downloadUrl) {
          crimeImagesUrls.add(downloadUrl);
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: purpleDark,
            content: Text(
              "You can only upload four (4) images",
              style: TextStyle(color: greyPrimary),
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    });
  }

  void updateMapView(LatLng position) {
    _mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: position,
          zoom: 16.0,
        ),
      ),
    );
  }

  void updateMapMarkers(List<LocationModel> locations) {
    Set<Marker> tempMarkers = {};

    locations.forEach((location) {
      BitmapDescriptor markerColor;

      if (location.reportNumber <= 5) {
        markerColor =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen);
      } else if (location.reportNumber > 5 && location.reportNumber <= 20) {
        markerColor =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange);
      } else if (location.reportNumber > 20) {
        markerColor =
            BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
      }

      tempMarkers.add(Marker(
        markerId: MarkerId(location.address),
        icon: markerColor,
        position: LatLng(location.latitude, location.longitude),
        onTap: () {
          if (location.crimeImages.isNotEmpty)
            showDialog(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return Dialog(
                        child: Padding(
                          padding: EdgeInsets.only(
                            top: SizeConfig.blockSizeHorizontal * 5,
                            bottom: SizeConfig.blockSizeHorizontal * 5,
                          ),
                          child: CarouselSlider(
                            options: CarouselOptions(
                              height: 400.0,
                              enableInfiniteScroll: false,
                              enlargeCenterPage: true,
                            ),
                            items: location.crimeImages.map((i) {
                              return Builder(
                                builder: (BuildContext context) {
                                  return FadeInImage.memoryNetwork(
                                    placeholder: kTransparentImage,
                                    image: i,
                                  );
                                },
                              );
                            }).toList(),
                          ),
                        ),
                      );
                    },
                  );
                });
        },
        infoWindow: InfoWindow(
          title: "Crime${location.reportNumber > 1 ? "s" : ""} Reported",
          snippet: location.reportNumber.toString(),
        ),
      ));
    });

    // setState(() {
    _markers.addAll(tempMarkers);
    // });
  }

  void _displayLogoutAlert(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return LogOutAlert();
      },
    );
  }

  void showPickImageAlert(BuildContext context) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text(
                          "Gallery",
                          style: TextStyle(
                            color: purplePrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      onPressed: () {
                        getImage(context, ImageSource.gallery).then((value) {
                          Navigator.pop(context);
                        });
                        // Navigator.pop(context);
                      },
                    ),
                    TextButton(
                      child: Container(
                        margin: EdgeInsets.all(10.0),
                        child: Text(
                          "Camera",
                          style: TextStyle(
                            color: purplePrimary,
                            fontSize: 15.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      onPressed: () {
                        getImage(context, ImageSource.camera).then((value) {
                          Navigator.pop(context);
                        });
                        // Navigator.pop(context);
                      },
                    )
                  ],
                ),
              );
            },
          );
        });
  }

  void addCrime() {
    LocationModel location = LocationModel(
      address: _crimeAddress,
      latitude: _crimePosition.latitude,
      longitude: _crimePosition.longitude,
      reportNumber: 1,
      crimeImages: crimeImagesUrls,
    );

    locationService.insertLocation(location);

    setState(() {
      _saving = false;
      crimeLocationBarController.clear();
      _crimePosition = null;
      _crimeAddress = "";
      selectedImages.clear();
    });
    panelController.close();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: purplePrimary,
        content: Text(
          "Crime Reported!",
          style: TextStyle(color: greyLighter),
        ),
        duration: Duration(seconds: 10),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);

    final panelHeightClosed = SizeConfig.blockSizeVertical * 15;
    final panelHeightOpened = SizeConfig.blockSizeVertical * 55;
    final panelBorderRadius = BorderRadius.only(
      topLeft: Radius.circular(15.0),
      topRight: Radius.circular(15.0),
    );

    // List<LocationModel> crimeLocations =
    //     Provider.of<List<LocationModel>>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: StreamBuilder(
        stream: fireBaseFirestoreRef
            .collection(RealtimeDatabaseKeys.locations)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<LocationModel> locations = [];
            snapshot.data.docs.forEach((doc) {
              locations.add(LocationModel.fromJson(doc.data()));
            });

            updateMapMarkers(locations);
          }

          return Stack(
            alignment: AlignmentDirectional.center,
            children: [
              // DraggableScrollableSheet(builder: builder),
              SlidingUpPanel(
                controller: panelController,
                borderRadius: panelBorderRadius,
                minHeight: panelHeightClosed,
                maxHeight: panelHeightOpened,
                parallaxEnabled: true,
                backdropEnabled: true,
                parallaxOffset: 0.2,
                panelBuilder: (ScrollController sc) {
                  return mainPanelWidget(sc);
                },
                onPanelSlide: (position) => setState(() {
                  final maxPanelScrollExtent =
                      panelHeightOpened - panelHeightClosed;

                  fabHeight = position * maxPanelScrollExtent + fabHeightClosed;
                }),
                body: Stack(
                  alignment: AlignmentDirectional.topCenter,
                  children: [
                    mapsWidget(),
                    Positioned(
                      top: SizeConfig.blockSizeVertical * 7,
                      left: SizeConfig.blockSizeHorizontal * 5,
                      child: logoutWidget(),
                    ),
                  ],
                ),
              ),
              Positioned(
                bottom: fabHeight,
                right: 10,
                child: currentLocationWidget(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget logoutWidget() => SizedBox(
        height: 50,
        width: 50,
        child: FloatingActionButton(
          heroTag: "logout",
          elevation: 20.0,
          backgroundColor: Colors.white,
          onPressed: () => _displayLogoutAlert(context),
          child: Icon(
            Icons.power_settings_new,
            color: Colors.red.shade600,
          ),
        ),
      );

  Widget _previewImage() => Container(
        height: 100,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          physics: BouncingScrollPhysics(),
          itemCount: selectedImages.length + 1,
          itemBuilder: (BuildContext context, int i) {
            if (selectedImages.isEmpty || i == selectedImages.length) {
              return Padding(
                padding: EdgeInsets.only(
                  right: SizeConfig.blockSizeHorizontal * 5,
                  left: SizeConfig.blockSizeHorizontal * 5,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: InkWell(
                    onTap: () {
                      if (selectedImages.length < 4) {
                        showPickImageAlert(context);
                      }
                    },
                    child: Container(
                      color: Colors.grey[300],
                      height: SizeConfig.blockSizeHorizontal * 30,
                      width: SizeConfig.blockSizeHorizontal * 25,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.add,
                            size: 17.0,
                            color: Colors.black26,
                          ),
                          Text(
                            "PHOTO",
                            style: TextStyle(
                                fontSize: 11.0, color: Colors.black26),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return Padding(
              padding: EdgeInsets.only(
                left: SizeConfig.blockSizeHorizontal * 5,
                // right: SizeConfig.blockSizeHorizontal * 5,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(
                  10.0,
                ),
                child: Stack(
                  children: [
                    Image.file(
                      selectedImages[i],
                      fit: BoxFit.cover,
                      height: SizeConfig.blockSizeHorizontal * 30,
                      width: SizeConfig.blockSizeHorizontal * 25,
                    ),
                    Positioned(
                      top: 2,
                      right: 2,
                      child: CircleAvatar(
                        backgroundColor: purpleDark,
                        radius: 12,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          icon: Icon(
                            Icons.close,
                            size: 12,
                          ),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              selectedImages.removeAt(i);
                            });
                          },
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      );

  Widget mainPanelWidget(ScrollController sc) {
    final crimeLocationBar = Container(
      width: SizeConfig.blockSizeHorizontal * 90,
      padding: EdgeInsets.only(
        bottom: SizeConfig.blockSizeVertical * 2,
      ),
      child: TypeAheadFormField(
        key: new Key("locationFieldKey"),
        autovalidateMode: AutovalidateMode.disabled,
        getImmediateSuggestions: true,
        textFieldConfiguration: TextFieldConfiguration(
          focusNode: _focus,
          onSubmitted: (value) =>
              SystemChannels.textInput.invokeMethod('TextInput.hide'),
          style: TextStyle(color: Colors.black),
          keyboardType: TextInputType.text,
          controller: crimeLocationBarController,
          onChanged: (value) => null,
          cursorColor: Colors.black,
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: EdgeInsets.all(8.0),
              child: Image(
                image: AvailableIcons.location["assetImage"],
                height: 1,
                width: 1,
              ),
            ),
            suffixIcon: InkWell(
              child: Icon(
                Icons.clear,
                color: greyPrimary,
              ),
              onTap: () {
                setState(() {
                  crimeLocationBarController.clear();
                  _crimeAddress = "";
                  _crimePosition = null;
                });
              },
            ),
            contentPadding: EdgeInsets.symmetric(
              vertical: 20.0,
              horizontal: 20.0,
            ),
            labelText: "Add a crime location",
            labelStyle: TextStyle(fontSize: 15.0),
            fillColor: Colors.red,
            filled: false,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              borderSide: BorderSide(color: purplePrimary, width: 3),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              borderSide: BorderSide(color: purplePrimary, width: 3),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              borderSide: BorderSide(
                color: purplePrimary,
                width: 3,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              borderSide: BorderSide(color: purplePrimary, width: 3),
            ),
          ),
        ),
        suggestionsCallback: (pattern) async {
          return await getLocations(input: pattern);
        },
        errorBuilder: (BuildContext context, Object error) => ListTile(
          title: Text(
            'No location selected',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
        ),
        noItemsFoundBuilder: (BuildContext context) => ListTile(
          title: Text(
            'No location found',
            style: TextStyle(color: Theme.of(context).errorColor),
          ),
        ),
        loadingBuilder: (BuildContext context) {
          return ListTile(title: Text('No location loaded'));
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSuggestionSelected: (suggestion) {
          setState(() {
            _crimeAddress = suggestion;
            getLocationFormAddress(
              suggestion,
            ).then((value) {
              _crimePosition = value;
            });
          });

          crimeLocationBarController.text = suggestion;
          SystemChannels.textInput.invokeMethod('TextInput.hide');
        },
      ),
    );

    final addLocationBtn = Padding(
      padding: EdgeInsets.only(
        top: SizeConfig.blockSizeVertical * 5,
        left: SizeConfig.blockSizeHorizontal * 5,
        right: SizeConfig.blockSizeHorizontal * 5,
      ),
      child: Container(
        height: SizeConfig.blockSizeVertical * 6,
        width: SizeConfig.blockSizeHorizontal * 100,
        child: Material(
          borderRadius: BorderRadius.circular(7.0),
          color: purplePrimary,
          elevation: 5.0,
          shadowColor: Colors.white70,
          child: MaterialButton(
            onPressed: () {
              if (!_saving) {
                if (_crimeAddress.isNotEmpty && _crimePosition != null) {
                  setState(() {
                    _saving = true;
                  });

                  Timer(Duration(seconds: 3), () {
                    addCrime();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: purpleDark,
                      content: Text(
                        "No location added",
                        style: TextStyle(color: greyPrimary),
                      ),
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              }
            },
            child: _saving
                ? Center(
                    child: Container(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                : Text(
                    "Add Location",
                    style: TextStyle(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.w500,
                      fontFamily: AvailableFonts.primaryFont,
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
      ),
    );

    return SingleChildScrollView(
      controller: sc,
      physics: BouncingScrollPhysics(),
      child: Column(
        children: [
          InkWell(
            onTap: () {
              if (panelController.isPanelOpen) {
                panelController.close();
              } else {
                panelController.open();
              }
            },
            child: Container(
              height: 5,
              width: 50,
              margin: EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: greyPrimary,
                borderRadius: BorderRadius.circular(
                  20,
                ),
              ),
            ),
          ),
          crimeLocationBar,
          Container(
            width: SizeConfig.blockSizeHorizontal * 95,
            padding: EdgeInsets.only(
              // top: SizeConfig.blockSizeVertical * 2,
              bottom: SizeConfig.blockSizeVertical * 2,
              left: SizeConfig.blockSizeHorizontal * 3,
              right: SizeConfig.blockSizeHorizontal * 3,
            ),
            child: Material(
              borderRadius: BorderRadius.circular(10.0),
              color: Colors.white,
              elevation: 10.0,
              shadowColor: Colors.white70,
              child: Padding(
                padding: EdgeInsets.only(
                  top: SizeConfig.blockSizeVertical * 2,
                  bottom: SizeConfig.blockSizeVertical * 2,
                  left: SizeConfig.blockSizeHorizontal * 4,
                  right: SizeConfig.blockSizeHorizontal * 4,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeVertical * 2,
                      ),
                      child: Text(
                        "Current Location",
                        style: TextStyle(
                          fontFamily: AvailableFonts.primaryFont,
                          color: purplePrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: SizeConfig.blockSizeVertical * 1,
                      ),
                      child: Text(
                        _crimeAddress.isEmpty
                            ? "No location selected"
                            : _crimeAddress,
                        style: TextStyle(
                          fontFamily: AvailableFonts.primaryFont,
                          color: purplePrimary,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.1,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _previewImage(),
          addLocationBtn
        ],
      ),
    );
  }

  Widget mapsWidget() => GoogleMap(
        myLocationButtonEnabled: false,
        zoomGesturesEnabled: true,
        zoomControlsEnabled: false,
        tiltGesturesEnabled: true,
        compassEnabled: false,
        mapToolbarEnabled: false,
        padding: EdgeInsets.only(bottom: 5, top: 80),
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
          _controller.complete(controller);
          getCurrentLocation();
        },
        onCameraMove: (CameraPosition position) {},
        mapType: _currentMapType,
        markers: _markers,
        initialCameraPosition: _initialCameraPosition,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
          Factory<OneSequenceGestureRecognizer>(
            () => EagerGestureRecognizer(),
          ),
        ].toSet(),
      );

  Widget currentLocationWidget() => FloatingActionButton(
        heroTag: "currentLocation",
        backgroundColor: Colors.white,
        mini: true,
        child: Icon(
          Icons.my_location_outlined,
          color: purplePrimary,
        ),
        onPressed: () {
          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: _currentPosition,
                zoom: 16.0,
              ),
            ),
          );
        },
      );
}
