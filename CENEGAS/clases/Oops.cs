using System;
using System.IO;
using System.Web;
namespace Mi.Clases
{
	public class Oops
	{
		public static void Responder(HttpResponse response, Exception exception) {
			response.Output.WriteLine(@"
<!DOCTYPE html>
<html><head>
<script type=""text/javascript"">");
			FileStream fileStream = null;
			try
			{
				int b;
				fileStream = File.OpenRead(HttpRuntime.AppDomainAppPath + "\\js\\jquery-3.1.1.min.js");
				while ((b = fileStream.ReadByte()) >= 0) response.OutputStream.WriteByte((byte)b);
			}
			catch { }
			finally
			{
				if (fileStream != null) try { fileStream.Close(); }
					catch { }
			}
			response.Output.Write(@"
	function _onload(){
		var palabra='';
		var center1 = $('#center1');
		center1.css({
			width:$(window).width(),
			height:$(window).height()
		});
		var table1 = document.getElementById('table1')
		table1.style.width=(window.innerWidth/2)+'px';
		table1.style.height=(window.innerHeight/3)+'px';
		table1.style.position='relative';
		table1.style.top=(window.innerHeight/3)+'px';
		var table2 = document.getElementById('table2')
		table2.style.position='relative';
		table2.style.top=(window.innerHeight*0.1)+'px';
		table2.style.width=(window.innerWidth*0.9)+'px';
		var input1=$('#input1');
		input1.height(1);
		input1.width(1);
		input1.css({
			border:'none',
			'font-size':1,
			color:'white'
		});
		input1.keypress(function(event){
			palabra=palabra+String.fromCharCode(event.which);
			if(palabra.match(/ayuda/i)){
				table1.style.display='none';
				table2.style.display='table';
			}
		});
	input1.focus();
	}
</script>
</head><body style=""margin:0px; overflow:hidden;"" onload=""_onload();"">
	<center id=""center1"">
		<div id=""div1""/>
		<table border=""1"" cellpadding=""15"" id=""table1"">
			<tr><td style=""background-color:blue;font-size:20pt; color:white; text-align:center;"">ERROR NO CONTROLADO</td></tr>
			<tr><td>Por favor pide ayuda a soporte técnico.<input id=""input1""/></td></tr>
		</table>
		<table style=""display:none;"" border=""1"" id=""table2"">
			<tr><td>Message</td><td>");
			response.Output.Write(exception.Message);
			response.Output.Write(@"
			</td></tr>
			<tr><td>Source</td><td>");
			response.Output.Write(exception.Source);
			response.Output.Write(@"
			</td></tr>
			<tr><td>StackTrace</td><td>");
			response.Output.Write(exception.StackTrace);
			response.Output.Write(@"
			</td></tr>
		</table>
	</center>
</body></html>");
			response.End();
		}
	}
}