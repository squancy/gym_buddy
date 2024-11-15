import 'package:get_time_ago/get_time_ago.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:transparent_image/transparent_image.dart';
import 'helpers.dart' as helpers;
import 'time_ago_format.dart';

Widget buildInfoPart(field, post, context) {
  String val;
  if (field == 'when') {
    val = DateFormat('MM-dd hh:mm a').format(post[field].toDate()).toString();
  } else {
    val = post[field];
  }
  IconData? icon;
  switch (field) {
    case 'gym':
      icon = Icons.location_pin;
    case 'when':
      icon = Icons.calendar_month_rounded;
    case 'day_type':
      icon = Icons.sports_gymnastics_rounded;
  }
  return val.isNotEmpty ? Padding(
    padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
    child: Row(
      children: [
        Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary,),
        SizedBox(width: 10,),
        Text(val, style: TextStyle(
          fontWeight: FontWeight.bold
        ),)
      ],
    )
    ) : Container();
}

Widget postBuilder(post, displayUsername, context) {
  GetTimeAgo.setCustomLocaleMessages('en', CustomMessages());
  return Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                helpers.ProfilePicPlaceholder(radius: 20,),
                ClipOval(
                  child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage,
                    image: post['author_profile_pic_url'],
                    height: 40,
                    width: 40,
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(milliseconds: 250),
                  )      
                )
              ]
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                    child: Row(
                      children: [
                        Flexible(
                          child: Text(
                            displayUsername,
                            style: TextStyle(
                              fontWeight: FontWeight.bold
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(8, 2, 8, 0),
                          child: Container( 
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary
                            ),
                            width: 5,
                            height: 5,
                          ),
                        ),
                        Text(
                          GetTimeAgo.parse(post['date'].toDate()),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary
                          ),
                        )
                      ]
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                    child: Text(post['content'], overflow: TextOverflow.ellipsis, maxLines: 10,),
                  ),
                  buildInfoPart('gym', post, context),
                  buildInfoPart('when', post, context),
                  buildInfoPart('day_type', post, context),
                ],
              ),
            )
          ]
        ),
      ),
      post['download_url_list'].isEmpty ? Container() : Padding(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
        child: helpers.horizontalImageViewer(
          showImages: true,
          images: post['download_url_list'],
          isPost: false
        ),
      ),
      Divider(
        color: Colors.white12
      ),
    ],
  );
}