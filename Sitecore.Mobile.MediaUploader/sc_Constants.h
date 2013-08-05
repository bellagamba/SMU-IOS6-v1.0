//
//  Constants.h
//  Sitecore.Mobile.MediaUploader
//
//  Created by andrea bellagamba on 6/19/13.
//  Copyright (c) 2013 Sitecore. All rights reserved.
//

#ifndef Sitecore_Mobile_MediaUploader_sc_Constants_h
#define Sitecore_Mobile_MediaUploader_sc_Constants_h

#define SLIDE_FRAME_MOVEMENT_DISTANCE 70
#define SLIDE_FRAME_MOVEMENT_DURATION 0.3f
#define MEDIA_LIBRARY_ID @"{3D6658D8-A0BF-4E75-B3E2-D050FABCF4E1}"
#define MEDIA_LIBRARY_IMAGE_FOLDER_ID @"{15451229-7534-44EF-815D-D93D6170BFCB}"
#define MEDIA_LIBRARY_FOLDER @"media library"
#define MEDIA_LIBRARY_FOLDER_SLASH [NSString stringWithFormat:@"%@/", MEDIA_LIBRARY_FOLDER]

#define NORMAL_ROW_BG [UIColor whiteColor]
#define UPLOADED_ROW_BG [UIColor colorWithRed:0.0 green:0.5 blue:0.0 alpha:1.0]
#define ERROR_LABEL_COLOR [UIColor colorWithRed:0.8 green:0.225 blue:0.225 alpha:1.0]
#define ERROR_ROW_BG [UIColor colorWithRed:0.8 green:0.225 blue:0.225 alpha:1.0]
#define LABEL_BG [UIColor colorWithRed:0.98 green:0.98  blue:0.98  alpha:1.0]
#define DARK_LABEL_BG [UIColor colorWithRed:0.9 green:0.9  blue:0.9  alpha:1.0]
#define TRANSPARENT_LABEL_BG [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.0]
#define UPLODIMAGESIZE_SMALL 0
#define UPLODIMAGESIZE_MEDIUM 1
#define UPLODIMAGESIZE_ACTUAL 2

enum {
    MEDIASTATUS_UNDEFINED,
    MEDIASTATUS_PENDING,
    MEDIASTATUS_UPLOADED,
    MEDIASTATUS_REMOVED
};



#endif
