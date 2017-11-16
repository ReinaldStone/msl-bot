#include-once
#include "../imports.au3"

#cs
    Function: Retrieves Color from bitmap handle and converts to 0xFFFFFF hex format
    Parameter:
        $iX: y-Coordinate
        $iY: x-Coordinate
        $hBitmap: Bitmap handle
    Return: Hex String => 0xFFFFFF.
#ce
Func getColor($iX, $iY, $hBitmap = $g_hBitmap)
    Return "0x" & Hex(_GDIPlus_BitmapGetPixel($hBitmap, $iX, $iY), 6)
EndFunc

#cs
    Function: Checks if pixel(s) equal or fit within the range of variation inside Bitmap
    Parameters:
        $vArg: Can be formated to be: [[x, y, color], [...]] or ["x, y, color", "..."] or "x,y,color|..."
        $iVariation: The maximum color variation compared to the actual pixel.
        $hBitmap: Bitmap to compare the pixels for.
    Returns: Boolean => if pixel(s) meet condition.
    Extended: List of color1, color2, and their variations.
#ce
Func isPixel($vArg, $iVariation = 10, $hBitmap = $g_hBitmap)
    Local $aPixels[0] ;pixels to check

    If ($vArg = "") Or ($vArg = -1) Then ;returns early if vArg is empty
        $g_sErrorMessage = "(isPixel:17) => No Arguments Found."
        Return -1
    EndIf

    ;Fixing argument format to [[x, y, color], [...]]
    If isArray($vArg) = True Then
        If isArray($vArg[0]) = True Then
            ;Expected format: "[[x, y, color], [...]]"
            Local $aPixel = $vArg
        Else
            If StringInStr($vArg[0], ",") = True Then
                ;Expected format: ["x,y,color", "..."]
                Local Const $iSize = UBound($vArg)
                ReDim $aPixels[$iSize]

                For $i = 0 To $iSize-1
                    Local $t_aPixel = StringSplit($vArg[$i], ",", $STR_NOCOUNT)
                    If UBound($t_aPixel) <> 3 Then ContinueLoop

                    Local $t_iX = StringStripWS($t_aPixel[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    Local $t_iY = StringStripWS($t_aPixel[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
                    Local $t_cColor = StringStripWS($t_aPixel[2], $STR_STRIPLEADING + $STR_STRIPTRAILING)

                    Local $t_aFormatedPixel = [$t_iX, $t_iY, $t_cColor]

                    ReDim $aPixels[UBound($aPixels)+1]
                    $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
                Next
            Else
                ;Expected format: ["x", "y", "color"]
                Local $t_aFormatedPixel = [$vArg[0], $vArg[1], $vArg[2]]

                ReDim $aPixels[UBound($aPixels)+1]
                $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
            EndIf
        EndIf
    Else
        ;Expected format: "x,y,color|..."
        Local $t_aPixelSet = StringSplit($vArg, "|", $STR_NOCOUNT)
        Local Const $t_eSize = UBound($t_aPixelSet)

        For $i = 0 To $t_eSize-1
            Local $t_aPixel = StringSplit($t_aPixelSet[$i], ",", $STR_NOCOUNT)
            If UBound($t_aPixel) <> 3 Then ContinueLoop

            Local $t_iX = StringStripWS($t_aPixel[0], $STR_STRIPLEADING + $STR_STRIPTRAILING)
            Local $t_iY = StringStripWS($t_aPixel[1], $STR_STRIPLEADING + $STR_STRIPTRAILING)
            Local $t_cColor = StringStripWS($t_aPixel[2], $STR_STRIPLEADING + $STR_STRIPTRAILING)

            Local $t_aFormatedPixel = [$t_iX, $t_iY, $t_cColor]

            ReDim $aPixels[UBound($aPixels)+1]
            $aPixels[UBound($aPixels)-1] = $t_aFormatedPixel
        Next
    EndIf

    ;checking if pixel is within variation
    Local Const $iTotalPixels = UBound($aPixels) ;Total pixels

    ;Debug information ===============================
    Global $g_vDebug[1][3]
    $g_vDebug[0][0] = "Color1"
    $g_vDebug[0][1] = "Color2"
    $g_vDebug[0][2] = "Variation"
    ;====================================================

    For $i = 0 To $iTotalPixels-1
        Local $t_aCurrPixel = $aPixels[$i]

        Local $t_iX = $t_aCurrPixel[0] ;x coordinate
        Local $t_iY = $t_aCurrPixel[1] ;y coordinate
        Local $t_cColor = $t_aCurrPixel[2] ;color

        Local $t_cColor2 = getColor($t_iX, $t_iY, $hBitmap) ;current color in position
        Local $t_iColorDifference = compareColors($t_cColor, $t_cColor2)

        ;Extended information ===============================
        ReDim $g_vDebug[UBound($g_vDebug)+1][3]
        Local $t_iIndex = UBound($g_vDebug)-1

        $g_vDebug[$t_iIndex][0] = $t_cColor
        $g_vDebug[$t_iIndex][1] = $t_cColor2
        $g_vDebug[$t_iIndex][2] = $t_iColorDifference
        ;====================================================

        If $t_iColorDifference > $iVariation Then
            Return False
        EndIf
    Next

    Return True
EndFunc

#cs
    Function: If one of the pixel sets are true then returns true
    Parameters:
        $aPixelSet: Format = [[[x,y,color], [...]], [[...], [...]]] or ["x,y,color|...", "...|..."] or "x,y,color|.../...|..." (Array of Pixels Sets)
        $iVariation: The maximum color variation compared to the actual pixel.
        $hBitmap: Bitmap to compare the pixels for.
    Returns: Boolean
#ce
Func isPixelOR($aPixelSet, $iVariation = 10, $hBitmap = $g_hBitmap)
    If isArray($aPixelSet) = False Then ;expected format: "x,y,color|.../...|..."
        $aPixelSet = StringSplit($aPixelSet, "/", $STR_NOCOUNT)
    EndIf

    Local $t_eSize = UBound($aPixelSet)

    For $i = 0 To $t_eSize-1
        If isPixel($aPixelSet[$i], $iVariation, $hBitmap) = True Then Return True
    Next

    Return False
EndFunc

#cs
    Function: Calculates difference of two color.
    Parameter:
        $cColor1: First color.
        $cColor2: Second color.
        $nRetType: Return type.
    Returns: $nRetType:: 1=Returns max variation. 0=Returns array of max variation between Red, Green, Blue
#ce
Func compareColors($nColor1, $nColor2, $nRetType=1)
	Local $nRet[3]
	$nRet[0] = Abs(_ColorGetRed($nColor1) - _ColorGetRed($nColor2))
	$nRet[1] = Abs(_ColorGetGreen($nColor1) - _ColorGetGreen($nColor2))
	$nRet[2] = Abs(_ColorGetBlue($nColor1) - _ColorGetBlue($nColor2))
	If $nRetType = 1 Then
		Return _Max($nRet[0], _Max($nRet[1], $nRet[2]))
	Else
		Return $nRet
	EndIf
EndFunc

#cs
	Function: Looks for a color within a certion boundary
	Parameters:
		$startingPoint: A point array [x, y] or string "x,y" of the top left of the boundary
		$size: A point array [x, y] or string "x,y" of the size of the boundary
		$variation: Maximum variation from the original color
		$skipx: Number of pixels to skip on the x axis
	    $skipy: Number of pixels to skip on the y axis
	Return:
		- The point array of the pixel.
		*Returns -1 if not found.
#ce

Func findColor($startingPoint, $size, $color, $variation = 10, $skipx = 1, $skipy = 1)
	Local $x, $y
	Local $width, $height

	;Split starting point array/string to its variables
	If isArray($startingPoint) = False Then
		Local $split = StringSplit(StringStripWS($startingPoint, 8), ",", 2)
		$x = $split[0]
		$y = $split[1]
	Else
		$x = $startingPoint[0]
		$y = $startingPoint[1]
	EndIf

	If isArray($size) = False Then
		Local $split = StringSplit(StringStripWS($size, 8), ",", 2)
		$width = $split[0]
		$height = $split[1]
	Else
		$width = $size[0]
		$height = $size[1]
	EndIf

	;Process
	For $x1 = $x to $x+$width Step $skipx
		For $y1 = $y to $y+$height Step $skipy
			Local $tempPixel = [$x1, $y1, $color]
			If isPixel($tempPixel, $variation) = True Then
				Local $tempPoint = [$x1, $y1]
				Return $tempPoint
			EndIf
		Next
	Next

	;If not found
	Return -1
EndFunc