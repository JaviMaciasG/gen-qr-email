#!/bin/bash

DATA="data.csv"
FILE="message.txt"

QR_TOOL=qrencode
QR_OPTIONS="-s 15 -m 20"
CONVERT_TOOL=convert

while read -r line
do
    # Parse input file
    NAME=`echo $line | cut -f 1 -d ";" | cut -f 2 -d "," | xargs`
    SURNAME=`echo $line | cut -f 1 -d ";" | cut -f 1 -d "," | xargs `
    EMAIL=`echo $line | cut -f 2 -d ";" | xargs`
    URL=`echo $line | cut -f 3 -d ";" | xargs`

    # Shorten URL
    URL_SHORT=`curl https://tinyurl.com/api-create.php\?url\=$URL`

    echo "Shortened URL, from [$URL] to [$URL_SHORT]"

    # Define filename related variables
    BASENAME=`echo $SURNAME$NAME|tr -d " ,"`
    QR_FILENAME=$BASENAME.png
    QRTX_FILENAME=$BASENAME+txt.png
    PDF_QRTX_FILENAME=$BASENAME+txt.pdf
    TX_FILENAME=$BASENAME.txt

    # Generate QR
    $QR_TOOL $QR_OPTIONS -o $QR_FILENAME $URL
    $QR_TOOL $QR_OPTIONS -o short-$QR_FILENAME $URL_SHORT

    # Prepare text inlining
    INLINE_TEXT1="text 100,100 \"Processing for $NAME $SURNAME\""
    INLINE_TEXT2="text 100,140 \"$URL\""
    INLINE_TEXT3="text 100,170 \"$URL_SHORT\""

    # Add text to image
    convert -pointsize 30 -fill black -draw "$INLINE_TEXT1" -pointsize 20 -draw "$INLINE_TEXT2" -pointsize 20 -draw "$INLINE_TEXT3" $QR_FILENAME $QRTX_FILENAME
    convert -pointsize 30 -fill black -draw "$INLINE_TEXT1" -pointsize 20 -draw "$INLINE_TEXT2" -pointsize 20 -draw "$INLINE_TEXT3" short-$QR_FILENAME short-$QRTX_FILENAME

    # Convert to pdf, JIC it is more convenient
    $CONVERT_TOOL $QRTX_FILENAME $PDF_QRTX_FILENAME
    $CONVERT_TOOL short-$QRTX_FILENAME short-$PDF_QRTX_FILENAME

    echo "Sending email to [$NAME $SURNAME] [EMAIL=$EMAIL] [URL=$URL] attaching [$QR_FILENAME]..."

    # overwrite here cc and/or dest_email if required
    cc=$CC_EMAIL
    to=$EMAIL

    cat $FILE|sed "s#__NAME__#$NAME#g"|sed "s#__SURNAME__#$SURNAME#g"|sed "s#__EMAIL__#$EMAIL#g"|sed "s#__URL__#$URL#g"|sed "s#__EMAIL__#$EMAIL#g" > $TX_FILENAME
    mutt -s "Test messages with QR's & more" -c $cc $to -a "$QRTX_FILENAME" -a "$PDF_QRTX_FILENAME" -a "short-$QRTX_FILENAME" -a "short-$PDF_QRTX_FILENAME" < $TX_FILENAME

done < "$DATA"
