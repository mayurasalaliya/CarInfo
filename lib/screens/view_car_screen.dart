import 'dart:ui' as ui;
import 'package:car_info/model/car_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

enum Flag {
  visible,
  invisible,
}

class ViewCar extends StatefulWidget {
  final String value;

  const ViewCar(this.value, {Key? key}) : super(key: key);

  @override
  _ViewCarState createState() => _ViewCarState();
}

class _ViewCarState extends State<ViewCar> {

  String? carName;
  double? safetyRating;
  final ScrollController scrollController = ScrollController();
  bool isLoading = true;
  late double _height;
  Flag safety = Flag.invisible;
  Flag capacity = Flag.invisible;
  Flag other = Flag.invisible;
  Flag engineTerminologies = Flag.invisible;
  Flag attributes = Flag.invisible;
  Flag brakesTyres = Flag.invisible;
  CarModel carModel = CarModel();

  @override
  void initState() {
    super.initState();
    getCarDetails();
  }

  @override
  Widget build(BuildContext context) {
    RenderErrorBox.backgroundColor = Colors.white;
    RenderErrorBox.textStyle = ui.TextStyle(color: Colors.white);
    _height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: (isLoading) ? const Center(child: CircularProgressIndicator()):
        NestedScrollView(
          controller: scrollController,
          headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
            return <Widget>[
              SliverAppBar(
                excludeHeaderSemantics: true,
                expandedHeight: _height / 4.0,
                backgroundColor: Colors.transparent,
                floating: false,
                pinned: false,
                snap: false,
                forceElevated: innerBoxIsScrolled,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.black45,
                  ),
                  onPressed: () {
                    //go back button
                    Navigator.of(context).pop();
                  }
                ),
                flexibleSpace: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return FlexibleSpaceBar(
                      collapseMode: CollapseMode.pin,
                      centerTitle: true,
                      background: SizedBox(
                        child: Image.network(
                          carModel.image!,
                          loadingBuilder: (context, child, loadingProgress) {
                            if(loadingProgress == null) return child;
                            return const Center(child: CircularProgressIndicator());
                          },
                          errorBuilder:(BuildContext context, Object exception,
                              StackTrace? stackTrace) {
                            return const Center(child: CircularProgressIndicator());
                          },
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ];
          },
          body: Theme(
            data: Theme.of(context).copyWith(
              colorScheme: ColorScheme.fromSwatch().copyWith(secondary: Colors.black26)
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      carName!,
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 23,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      //price with inr symbol
                      '\u{20B9} ${carModel.price!}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 22,
                      ),
                    ),
                    (carModel.ncapRating!.compareTo("Not Tested") != 0) ?
                    const SizedBox(height: 10) : Container(),
                    (carModel.ncapRating!.compareTo("Not Tested") != 0) ?
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: List.generate(5, (index) {
                        return Icon(
                          index < safetyRating! ?
                          ((safetyRating! - index.toDouble()) == 0.5) ? Icons.star_half :
                          Icons.star : Icons.star_border,
                          color: Colors.green,
                        );
                      }),
                    ) : Container(),
                    const SizedBox(height: 25),
                    const ReturnText(title: "Overview", data: "",
                        textType: "big", iconChange: Flag.invisible),
                    ReturnText(title: "Body Type", data: carModel.bodyType!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Fuel Type", data: carModel.fuelType!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Mileage", data: carModel.mileage!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Seats", data: carModel.seats!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Airbags", data: carModel.airbags!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Audio System", data: carModel.audioSystem!,
                        textType: "", iconChange: Flag.invisible),
                    ReturnText(title: "Drivetrain", data: carModel.drivetrain!,
                        textType: "", iconChange: Flag.invisible),
                    const SizedBox(height: 20),
                    const ReturnText(title: "Features", data: "",
                        textType: "big", iconChange: Flag.invisible),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (safety == Flag.invisible) ?
                          safety = Flag.visible : safety = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Safety", data: "",
                          textType: "small", iconChange: safety),
                    ),
                    (safety == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Airbags", data: carModel.airbags!,
                              textType: "", iconChange: safety),
                          ReturnText(title: "NCAP Rating", data: carModel.ncapRating!,
                              textType: "", iconChange: safety),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (capacity == Flag.invisible) ?
                          capacity = Flag.visible : capacity = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Capacity", data: "",
                          textType: "small",iconChange: capacity),
                    ),
                    (capacity == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Seats", data: carModel.seats!,
                              textType: "", iconChange: capacity),
                          ReturnText(title: "Fuel Tank", data: carModel.fuelTank!,
                              textType: "", iconChange: capacity),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (other == Flag.invisible) ?
                          other = Flag.visible : other = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Other",  data: "",
                          textType: "small", iconChange: other),
                    ),
                    (other == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Audio System", data: carModel.audioSystem!,
                              textType: "", iconChange: other),
                          ReturnText(title: "Power Windows", data: carModel.powerWindows!,
                              textType: "", iconChange: other),
                          ReturnText(title: "Body Type", data: carModel.bodyType!,
                              textType: "", iconChange: other),
                          ReturnText(title: "Fuel Type", data: carModel.fuelType!,
                              textType: "", iconChange: other),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 20),
                    const ReturnText(title: "Specification",  data: "",
                        textType: "big", iconChange: Flag.invisible),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (engineTerminologies == Flag.invisible) ?
                          engineTerminologies = Flag.visible :
                          engineTerminologies = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Engine Terminologies",
                          data: "", textType: "small",
                          iconChange: engineTerminologies),
                    ),
                    (engineTerminologies == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Engine", data: carModel.engine!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Emission Standard", data: carModel.emissionNorm!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Mileage", data: carModel.mileage!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Max Torque", data: carModel.torque!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Max Power", data: carModel.power!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Transmission", data: carModel.transmission!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Gears", data: carModel.gears!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Drivetrain", data: carModel.drivetrain!,
                              textType: "", iconChange: engineTerminologies),
                          ReturnText(title: "Cylinders", data: carModel.cylinders!,
                              textType: "", iconChange: engineTerminologies),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (attributes == Flag.invisible) ?
                          attributes = Flag.visible :
                          attributes = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Attributes", data: "",
                          textType: "small", iconChange: attributes),
                    ),
                    (attributes == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Length", data: carModel.length!,
                              textType: "", iconChange: attributes),
                          ReturnText(title: "Width", data: carModel.width!,
                              textType: "", iconChange: attributes),
                          ReturnText(title: "Weight", data: carModel.weight!,
                              textType: "", iconChange: attributes),
                          ReturnText(title: "Height", data: carModel.height!,
                              textType: "", iconChange: attributes),
                          ReturnText(title: "Ground Clearance", data: carModel.groundClearance!,
                              textType: "", iconChange: attributes),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 5),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          (brakesTyres == Flag.invisible) ?
                          brakesTyres = Flag.visible :
                          brakesTyres = Flag.invisible;
                        });
                      },
                      child: ReturnText(title: "Brakes & Tyres", data: "",
                          textType: "small", iconChange: brakesTyres),
                    ),
                    (brakesTyres == Flag.visible) ?
                    Visibility(
                      child: Column(
                        children: <Widget>[
                          ReturnText(title: "Front Brakes", data: carModel.frontBrakes!,
                              textType: "", iconChange: brakesTyres),
                          ReturnText(title: "Rear Brakes", data: carModel.rearBrakes!,
                              textType: "", iconChange: brakesTyres),
                          ReturnText(title: "Wheels", data: carModel.wheels!,
                              textType: "", iconChange: brakesTyres),
                        ],
                      ),
                    ) :
                    Container(),
                    const SizedBox(height: 20),
                    const ReturnText(title: "Colors", data: "",
                        textType: "big", iconChange: Flag.invisible),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: displayColors(),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget displayColors() {
    List<String> colorNames = carModel.colours!.split(',');
    Map<String, Color> colors = {
      "black" : Colors.black,
      "white" : Colors.white,
      "silver" : Colors.black26,
      "grey" : Colors.black45,
      "red" : Colors.red,
      "blue" : Colors.blue,
      "lightblue" : Colors.lightBlueAccent,
      "brown" : Colors.brown,
      "orange" : Colors.orange,
    };
    return Row(
      children: <Widget>[
        for(int i = 0; i < colorNames.length; i++)
        Container(
          padding: const EdgeInsets.only(right: 20),
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: colors[colorNames[i]] ?? Colors.transparent,
              border: (colorNames[i].compareTo("white") == 0) ?
                  Border.all(width: 2, color: Colors.black12) :
                  Border.all(width: 0, color: Colors.transparent),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ],
    );
  }

  getCarDetails() async {
    setState(() {
      isLoading = true;
    });
    await FirebaseFirestore.instance.collection("cars")
        .where("carId", isEqualTo: widget.value).get().then((val) async {
      carModel = CarModel.fromJson(val.docs[0].data());
      carName = "${carModel.brand!} ${carModel.name!} ${carModel.variant!}";
      var nr = carModel.ncapRating!;
      if(nr.compareTo("Not Tested") == 0) {
        safetyRating = 0;
      }
      else {
        safetyRating = double.parse(nr);
      }
    });
    setState(() {
      isLoading = false;
    });
  }
}

class ReturnText extends StatelessWidget {

  final String title;
  final String data;
  final String textType;
  final Flag iconChange;

  const ReturnText({
    Key? key,
    required this.title,
    required this.data,
    required this.textType,
    required this.iconChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: (textType == "big" || textType == "small") ?
              Text(
                title,
                style: TextStyle(
                  color: (textType == "big") ? Colors.black : Colors.black54,
                  fontWeight: (textType == "big") ? FontWeight.w500 :
                      FontWeight.w800,
                  fontSize: (textType == "big") ? 22 : 19,
                ),
              ) :
              Text(
                title,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w400,
                  fontSize: 17,
                ),
              ),
            ),
            (textType != "big" && textType != "small") ?
            Text(
              data,
              style: const TextStyle(
                color: Colors.black54,
                fontWeight: FontWeight.w400,
                fontSize: 17,
              ),
            ) : Container(),
            if(textType == "small")
              Icon(
                (iconChange == Flag.invisible) ?
                Icons.keyboard_arrow_down_rounded :
                Icons.keyboard_arrow_up_rounded,
                color: Colors.blue,
              ),
          ],
        ),
        (textType == "big" || textType == "small") ?
        Divider(
          height: (textType == "big") ? 35 : 30,
          color: Colors.black54,
        ) :
        const Divider(
          height: 25,
          color: Colors.black54,
        )
      ],
    );
  }
}
