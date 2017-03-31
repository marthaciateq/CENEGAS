using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using Spire.Barcode;
namespace Mi.Control
{
	public class BarCode
	{
		public static byte[] Generate(BarcodeSettings barcodeSettings)
		{
			BarCodeGenerator barCodeGenerator = new BarCodeGenerator(barcodeSettings);
			Bitmap bitmapOriginal = (Bitmap)barCodeGenerator.GenerateImage();
			Bitmap bitmapRecortado =bitmapOriginal.Clone(new Rectangle(0, 15, bitmapOriginal.Width, bitmapOriginal.Height - 15), bitmapOriginal.PixelFormat);
			MemoryStream memoryStream = new MemoryStream();
			bitmapRecortado.Save(memoryStream, ImageFormat.Jpeg);
			return memoryStream.ToArray();

		}
		public static byte[] Code39(String data)
		{
			if (data == null || data.Length == 0) return new byte[0];
			BarcodeSettings barcodeSettings = new BarcodeSettings();
			barcodeSettings.Type = BarCodeType.Code39;
			barcodeSettings.Data = data;
			barcodeSettings.BarHeight = 30F;
			barcodeSettings.X = 1;
			barcodeSettings.ShowText = false;
			barcodeSettings.LeftMargin = 0;
			barcodeSettings.RightMargin = 0;
			barcodeSettings.TopMargin = 0;
			barcodeSettings.BottomMargin = 0;
			return Generate(barcodeSettings);
		}
		public static byte[] Pdf417(String data)
		{
			if (data == null || data.Length == 0) return new byte[0];
			BarcodeSettings barcodeSettings = new BarcodeSettings();
			barcodeSettings.Type = BarCodeType.Pdf417;
			barcodeSettings.Data = data;
			barcodeSettings.Y = 3;
			barcodeSettings.XYRatio = 3;
			barcodeSettings.ShowText = false;
			barcodeSettings.LeftMargin = 0;
			barcodeSettings.RightMargin = 0;
			barcodeSettings.TopMargin = 0;
			barcodeSettings.BottomMargin = 0;
			return Generate(barcodeSettings);
		}
	}
}
