import 'dart:math';

class ShopItem {
  ShopItem(this.id, this.name, this.description, this.price);

  final String id;
  final String name;
  final String description;
  final int price;
}

class CompassSkin extends ShopItem {
  CompassSkin(
      super.id, super.name, super.description, super.price, this.skinFilePath);

  final String skinFilePath;
}

class Shop {
  static String skinFolder = "assets/images/compass_skins/";

  static List<ShopItem> items = [
    CompassSkin(
      "default",
      "Default Compass",
      "This is the default compass. It shows a clear direction and features a simple arrow. "
          "It might not be the fanciest, but is probably the most functional.",
      0,
      "default_compass.png",
    ),
    CompassSkin(
      "abstract_compass",
      "Abstract Compass",
      "This design definitely is ... something. This was originally a draft for the "
          "logo of the app, but for obvious reasons, it didn't make it into the final release. ",
      200,
      "abstract_compass.png",
    ),
    CompassSkin(
      "arrow_compass",
      "Arrow",
      "It's an arrow. Pointing you in the correct direction. Does it get any better?",
      499,
      "arrow_compass.png",
    ),
    CompassSkin(
      "clock_compass",
      "Clock Compass",
      "This is a pretty bad clock. It doesn't tell the time. But it does show you the right direction!",
      499,
      "clock_compass.png",
    ),
    CompassSkin(
      "finger_compass",
      "Pointing Finger",
      "This compass is more than a compass. It's human, has a personality and really is different. You should buy it!",
      499,
      "finger.png",
    ),
    CompassSkin(
      "love_compass",
      "Love Compass",
      "This compass doesn't just show you the direction towards the coins. No! This compass "
          "will (almost) guarantee that you will find love on the way there. Isn't that amazing?",
      699,
      "love_compass.png",
    ),
    CompassSkin(
      "minimalist_compass",
      "Minimalist Compass",
      "When you're on a mission, you don't want anything to distract you. It's a point. That's the point. Lol.",
      1000,
      "minimalist_compass.png",
    ),
    CompassSkin(
      "graphic_design_compass",
      "graphic design is my passion",
      "Designing compasses is hard. And sometimes you fail. But! There is no but. This one is peak.",
      1699,
      "graphic_design_compass.png",
    ),
    CompassSkin(
      "fist_compass",
      "Boxing Glove",
      "IN YOUR FACE! This boxing glove is a clear mission to everyone in your way. Totally worth it.",
      4269,
      "fist.png",
    ),
    CompassSkin(
      "fancy_compass",
      "Fancy Compass",
      "Some people like to own fancy things. Some people like to spend loads of money. This is the compass for them! "
          "It doesn't just look expensive, it actually is!",
      19999,
      "fancy_compass.png",
    ),
  ];
}
