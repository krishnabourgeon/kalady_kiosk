package com.example.kalady_kiosk

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.hardware.usb.UsbManager
import android.text.Layout
import android.text.StaticLayout
import android.text.TextPaint
import android.util.Log
import com.kioskworldline.com.PrintCmd
import com.kioskworldline.com.UsbDriver
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class PrinterPlugin(
    private val context: Context
) : MethodChannel.MethodCallHandler {

    private var usbDriver: UsbDriver? = null

    // The printer only understands GB2312 (see PrintCmd.PrintString), which has
    // no Malayalam glyphs — those bytes come back as literal '?' on paper.
    // Malayalam lines are rendered to a bitmap using the system's default
    // typeface (Android's built-in font fallback handles Malayalam glyph
    // shaping reliably) and sent as an image so the printer's font ROM is
    // bypassed.

    init {
        usbDriver = UsbDriver(
            context.getSystemService(
                Context.USB_SERVICE
            ) as UsbManager,
            context
        )
    }

    private fun containsMalayalam(text: String): Boolean {
        return text.any { it.code in 0x0D00..0x0D7F }
    }

    private fun printLine(text: String) {
        if (text.isEmpty()) return
        if (containsMalayalam(text)) {
            printTextAsBitmap(text)
        } else {
            usbDriver?.write(PrintCmd.PrintString(text, 0))
        }
    }

    private fun printTextAsBitmap(text: String) {
        val paint = TextPaint(Paint.ANTI_ALIAS_FLAG).apply {
            color = Color.BLACK
            textSize = 24f
        }

        // Must match the printer's actual dot width (same width the 32-char
        // GB2312 text lines use elsewhere) - going wider makes the native
        // PrintBitmap() call silently fail, which falls back to GB2312 and
        // Malayalam stops printing.
        val maxLineWidthPx = 256
        val padding = 10

        val layout = StaticLayout(
            text,
            paint,
            maxLineWidthPx,
            Layout.Alignment.ALIGN_NORMAL,
            1f,
            0f,
            false
        )

        val bitmapHeight = layout.height.coerceAtLeast(40) + padding * 2
        val bitmap = Bitmap.createBitmap(maxLineWidthPx, bitmapHeight, Bitmap.Config.ARGB_8888)
        val canvas = Canvas(bitmap)
        canvas.drawColor(Color.WHITE)
        canvas.save()
        canvas.translate(padding.toFloat(), padding.toFloat())
        layout.draw(canvas)
        canvas.restore()

        val bytes = PrintCmd.PrintBitmap(bitmap)
        if (bytes != null) {
            usbDriver?.write(bytes)
        } else {
            Log.e(
                "PrinterPlugin",
                "PrintBitmap failed for \"$text\" (${bitmap.width}x${bitmap.height}); " +
                    "falling back to GB2312, Malayalam glyphs will not render"
            )
            // Fall back to the GB2312 path (renders as '?') rather than dropping the line silently.
            usbDriver?.write(PrintCmd.PrintString(text, 0))
        }
        bitmap.recycle()
    }

    override fun onMethodCall(
        call: MethodCall,
        result: MethodChannel.Result
    ) {

        when (call.method) {

            "connect" -> {

                val connected =
                    usbDriver?.openUsbDevice() ?: false

                result.success(connected)
            }

            "printText" -> {

                val text =
                    call.argument<String>("text") ?: ""

                usbDriver?.write(
                    PrintCmd.SetClean()
                )

                usbDriver?.write(
                    PrintCmd.PrintString(
                        text,
                        0
                    )
                )

                usbDriver?.write(
                    PrintCmd.PrintFeedline(2)
                )

                result.success(true)
            }

            "cutPaper" -> {

                usbDriver?.write(
                    PrintCmd.PrintCutpaper(0)
                )

                result.success(true)
            }

            "printReceipt" -> {
val temple =  call.argument<String>("temple") ?: ""
val templeAddress =  call.argument<String>("templeAddress") ?: ""
val templePlace =  call.argument<String>("templePlace") ?: ""
                val billNo =
                    call.argument<String>("billNo") ?: ""

                val date =
                    call.argument<String>("date") ?: ""

                val mode =
                    call.argument<String>("mode") ?: ""

                val total =
                    call.argument<String>("total") ?: ""

                val website =
                    call.argument<String>("website") ?: ""
                val items =call.argument<List<Map<String, Any?>>>("items")
        ?: emptyList()

                printReceipt(
                    temple,
                    templeAddress,
                    templePlace,
                    billNo,
                    date,
                    mode,
                    total,
                    website,
                    items
                )

                result.success(true)
            }

            else -> result.notImplemented()
        }
    }

    private fun printTwoColumn(
        left: String,
        right: String
    ) {

        val width = 32

        val spaces =
            (width - left.length - right.length)
                .coerceAtLeast(1)

        val line =
            left + " ".repeat(spaces) + right

        printLine(line)
    }

    private fun printReceipt(
        temple: String,
    templeAddress: String,
    templePlace: String,
    billNo: String,
    date: String,
    mode: String,
    total: String,
    website: String,
    items: List<Map<String, Any?>>
) {

  usbDriver?.write(PrintCmd.SetClean())

printLine(temple.uppercase())
printLine(templeAddress)
printLine(templePlace)

usbDriver?.write(PrintCmd.PrintFeedline(1))

printLine("--------------------------------")

    printTwoColumn(
        "Bill No: $billNo",
        date
    )

    printLine("--------------------------------")

    for (item in items) {

        val personId =
            item["personId"]?.toString() ?: ""

        val personName =
            item["personName"]?.toString() ?: ""

        val deity =
            item["deity"]?.toString() ?: ""

        val star =
            item["star"]?.toString() ?: ""

        val pooja =
            item["pooja"]?.toString() ?: ""

        val qty =
            item["qty"]?.toString() ?: ""

        val rate =
            item["rate"]?.toString() ?: ""

        val poojaDate =
            item["date"]?.toString() ?: ""

        val address =
            item["address"]?.toString() ?: ""

        printLine("$personId. $deity")

        printLine("$personName - $star")

        printLine("$pooja  $qty x $rate")

        if (poojaDate.isNotEmpty()) {
            printLine(poojaDate)
        }

        if (address.isNotEmpty()) {
            printLine(address)
        }

        usbDriver?.write(
            PrintCmd.PrintFeedline(1)
        )
    }

    printLine("--------------------------------")

    printTwoColumn(
        "Mode: $mode",
        "Total: Rs.$total"
    )

    usbDriver?.write(
        PrintCmd.PrintFeedline(1)
    )

    printLine("Book Online $website")

    usbDriver?.write(
        PrintCmd.PrintFeedline(3)
    )

    usbDriver?.write(
        PrintCmd.PrintCutpaper(0)
    )
}

}