/// Image shapes the share card renders in, each at the pixel size the
/// networks recommend for it.
enum ShareFormat {
  /// 9:16, full-screen stories and statuses.
  story(widthPx: 1080, heightPx: 1920),

  /// 4:5, the tallest a feed post shows uncropped (Instagram).
  portrait(widthPx: 1080, heightPx: 1350),

  /// 1:1, chats and square posts.
  square(widthPx: 1080, heightPx: 1080),

  /// 1.91:1, link-style feed posts (Facebook, LinkedIn).
  landscape(widthPx: 1200, heightPx: 628);

  final int widthPx;
  final int heightPx;

  const ShareFormat({required this.widthPx, required this.heightPx});

  double get aspectRatio => widthPx / heightPx;

  /// "9:16" and so on, for the picker.
  String get ratioLabel => switch (this) {
        ShareFormat.story => '9:16',
        ShareFormat.portrait => '4:5',
        ShareFormat.square => '1:1',
        ShareFormat.landscape => '1.91:1',
      };
}

/// Where the user says they're posting. Apps can't be targeted directly
/// from the share sheet, so the destination picks the image shape; the
/// system sheet then hands it to the app the user taps.
enum ShareDestination {
  whatsappMessage(ShareFormat.square, sendsCaption: true),
  whatsappStatus(ShareFormat.story),
  instagramPost(ShareFormat.portrait),
  instagramStory(ShareFormat.story),
  facebookPost(ShareFormat.landscape),
  facebookStory(ShareFormat.story),
  linkedinPost(ShareFormat.landscape, sendsCaption: true);

  final ShareFormat format;

  /// Whether the caption goes along with the image. Only apps that keep it
  /// get it: with text attached, iOS treats the image as a document and
  /// drops photo actions like Save Image, which stories rely on. The
  /// caption is copied either way.
  final bool sendsCaption;

  const ShareDestination(this.format, {this.sendsCaption = false});
}
