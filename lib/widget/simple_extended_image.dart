import 'dart:io';

import 'package:bujuan/common/constants/images.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';

class SimpleExtendedImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final String placeholder;
  final BoxShape shape;
  final BorderRadius? borderRadius;
  final Widget? replacement;
  final BoxFit? fit;
  final int? cacheWidth;

  const SimpleExtendedImage(this.url,
      {Key? key, this.width, this.height, this.placeholder = placeholderImage, this.replacement, this.fit, this.shape = BoxShape.rectangle, this.borderRadius, this.cacheWidth})
      : super(key: key);

  const SimpleExtendedImage.avatar(this.url,
      {Key? key,
      this.width,
      this.height,
      this.placeholder = avatarPlaceholderImage,
      this.replacement,
      this.fit,
      this.shape = BoxShape.circle,
      this.borderRadius,
      this.cacheWidth = 300})
      : super(key: key);

  @override
  SimpleExtendedImageState createState() {
    return SimpleExtendedImageState();
  }
}

class SimpleExtendedImageState extends State<SimpleExtendedImage> {
  @override
  Widget build(BuildContext context) {


    Widget image;

    if (widget.url.startsWith('http')) {
      image = CachedNetworkImage(
        httpHeaders: const {'User-Agent':'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/117.0.0.0 Safari/537.36 Edg/117.0.2045.35'},
        imageUrl: widget.url,
        width: widget.width,
        height: widget.height,
        fit: widget.fit??BoxFit.cover,
        useOldImageOnUrlChange: true,
        placeholder: (c, u) => Image.asset(
          widget.placeholder,
          fit: BoxFit.cover,
        ),
        errorWidget: (c,u,e) => Image.asset(
          widget.placeholder,
          fit: BoxFit.cover,
        ),
      );
    } else {
      image = ExtendedImage.file(
        borderRadius: widget.borderRadius,
        File(widget.url.split('?').first),
        width: widget.width,
        height: widget.height,
        fit: widget.fit,
        loadStateChanged: (state) {
          Widget image;
          switch (state.extendedImageLoadState) {
            case LoadState.loading:
              image = Image.asset(
                widget.placeholder,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              );
              break;
            case LoadState.completed:
              image = ExtendedRawImage(
                image: state.extendedImageInfo?.image,
                width: widget.width,
                height: widget.height,
                fit: BoxFit.cover,
              );
              break;
            case LoadState.failed:
              image = Image.asset(
                width: widget.width,
                height: widget.height,
                widget.placeholder,
                fit: BoxFit.cover,
              );
              break;
          }
          return image;
        },
      );
    }
    if (widget.shape == BoxShape.circle) {
      return ClipOval(
        child: image,
      );
    } else {
      return ClipRRect(
        borderRadius: widget.borderRadius ?? BorderRadius.circular(0),
        child: image,
      );
    }
  }
}
