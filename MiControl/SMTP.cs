using System;
using System.Collections;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.IO;
using System.Threading;
using System.Net.Mail;

namespace Mi.Control
{
	public class SMTP
	{
		private static String host;
		private static int port = 25;
		private static String defaultFrom;
		private static String defaultPassword;
		public static void Init()
		{
			String[] a = Config.GetConnectionString("SMTP").Value.Split(new char[] { '/' });
			if (a.Length != 4) throw new Exception("SMTP connection string errónea.");

			SMTP.host = a[0];
			try
			{
				SMTP.port = int.Parse(a[1]);
			}
			catch { }
			SMTP.defaultFrom = a[2];
			SMTP.defaultPassword = a[3];
		}
		public static void Send(DataSet dataSet)
		{
			bool isHTML;
			String template = null, idsesion, from, password, to, subject, body, cc, bcc, attachments;
			Dictionary<String, String> templates = new Dictionary<String, String>();
			StreamReader streamReader = null;
			SMTP smtp = new SMTP();
			foreach (DataTable dataTable in dataSet.Tables)
				if (dataTable.Columns.Contains("MailTo") && dataTable.Columns.Contains("MailSubject") && (dataTable.Columns.Contains("MailTemplate") || dataTable.Columns.Contains("MailBody")))
				{
					foreach (DataRow dataRow in dataTable.Rows)
					{
						idsesion = null; from = null; password = null; to = null; subject = null; body = null; isHTML = false; cc = null; bcc = null; attachments = null;
						isHTML = false;
						foreach (DataColumn dataColumn in dataTable.Columns)
						{
							if (dataColumn.ColumnName == "MailTemplate" && !dataRow.IsNull(dataColumn)) template = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailIdsesion" && !dataRow.IsNull(dataColumn)) idsesion = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailFrom" && !dataRow.IsNull(dataColumn)) from = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailPassword" && !dataRow.IsNull(dataColumn)) password = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailTo" && !dataRow.IsNull(dataColumn)) to = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailSubject" && !dataRow.IsNull(dataColumn)) subject = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailBody" && !dataRow.IsNull(dataColumn)) body = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailCc" && !dataRow.IsNull(dataColumn)) cc = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailBcc" && !dataRow.IsNull(dataColumn)) bcc = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailAttachments" && !dataRow.IsNull(dataColumn)) attachments = (String)dataRow.ItemArray[dataColumn.Ordinal];
							else if (dataColumn.ColumnName == "MailIsHTML" && !dataRow.IsNull(dataColumn) && (String)dataRow.ItemArray[dataColumn.Ordinal] == "S") isHTML = true;
							if (template != null)
							{
								if (!templates.ContainsKey(template))
									try
									{
										streamReader = new StreamReader(File.OpenRead(Config.AppPath + "mails\\" + template + ".html"));
										templates.Add(template, streamReader.ReadToEnd());
										streamReader.Close();
									}
									catch (Exception exception)
									{
										templates.Add(template, "MailError:" + exception.Message);
									}
								body = templates[template];
							}
						}
						foreach (DataColumn dataColumn in dataTable.Columns)
							if (!dataRow.IsNull(dataColumn))
								body = body.Replace(dataColumn.ColumnName, dataRow.ItemArray[dataColumn.Ordinal].ToString());
						body = body.Replace("ConfigWebHome", Config.WebHome);
						smtp.Add(idsesion, from, password, to, subject, body, isHTML, cc, bcc, attachments);
					}
				}
			smtp.Send();
		}
		private struct Mail
		{
			public String idsesion;
			public String from;
			public String password;
			public String to;
			public String subject;
			public String body;
			public bool isHTML;
			public String cc;
			public String bcc;
			public String attachments;
			public Mail(String idsesion, String from, String password, String to, String subject, String body, bool isHTML, String cc, String bcc, String attachments)
			{
				this.idsesion = idsesion;
				this.from = from;
				this.password = password;
				this.to = to;
				this.subject = subject;
				this.body = body;
				this.isHTML = isHTML;
				this.cc = cc;
				this.bcc = bcc;
				this.attachments = attachments;
			}
		}
		private List<Mail> list = new List<Mail>();
		public void Add(String idsesion, String from, String password, String to, String subject, String body, bool isHTML, String cc, String bcc, String attachments)
		{
			list.Add(new Mail(idsesion, from, password, to, subject, body, isHTML, cc, bcc, attachments));
		}
		public void Send()
		{
			(new Thread(new ThreadStart(this.Delegado))).Start();
		}
		private void Delegado()
		{
			if (this.list.Count == 0) return;
			SqlConnection sqlConnectionAdmin = null;
			SqlCommand sqlCommand = null;
			int idlog = -1;
			try
			{
				sqlConnectionAdmin = BD.Connection("Admin");
				foreach (Mail mail in this.list)
				{
					try
					{
						sqlCommand = new SqlCommand("SMTP.Send");
						if (mail.from != null) sqlCommand.Parameters.Add("from", SqlDbType.VarChar).Value = mail.from;
						if (mail.password != null) sqlCommand.Parameters.Add("password", SqlDbType.VarChar).Value = mail.password;
						if (mail.to != null) sqlCommand.Parameters.Add("to", SqlDbType.VarChar).Value = mail.to;
						if (mail.subject != null) sqlCommand.Parameters.Add("subject", SqlDbType.VarChar).Value = mail.subject;
						if (mail.body != null) sqlCommand.Parameters.Add("body", SqlDbType.VarChar).Value = mail.body;
						if (mail.isHTML) sqlCommand.Parameters.Add("isHTML", SqlDbType.VarChar).Value = "SI";
						if (mail.cc != null) sqlCommand.Parameters.Add("cc", SqlDbType.VarChar).Value = mail.cc;
						if (mail.bcc != null) sqlCommand.Parameters.Add("bcc", SqlDbType.VarChar).Value = mail.bcc;
						if (mail.attachments != null) sqlCommand.Parameters.Add("attachments", SqlDbType.VarChar).Value = mail.attachments;
						idlog = BD.LogInit(sqlCommand, sqlConnectionAdmin);
						SendMail(mail);
						BD.LogOk(idlog, sqlConnectionAdmin);
					}
					catch (Exception exception)
					{
						BD.LogException(idlog, exception, sqlConnectionAdmin);
					}
				}
			}

			catch { }
			finally
			{
				if (sqlConnectionAdmin != null) try { sqlConnectionAdmin.Close(); }
					catch { }
			}
		}
		private MailAddress[] ParseEmailAddresses(String emailAddresses)
		{
			if (emailAddresses == null) return null;

			String[] rows;
			ArrayList arrayList = new ArrayList();
			MailAddress[] mailAddresses;

			rows = emailAddresses.Split(new char[] { ',', '|', ';', ' ' });
			for (int i = 0; i < rows.Length; i++)
				if (rows[i].Trim().Length > 0 && rows[i].IndexOf('@') > -1) arrayList.Add(rows[i]);

			if (arrayList.Count == 0) return null;

			mailAddresses = new MailAddress[arrayList.Count];
			for (int i = 0; i < arrayList.Count; i++)
				mailAddresses[i] = new MailAddress((String)arrayList[i]);

			return mailAddresses;
		}
		private void SendMail(Mail mail)
		{
			MailMessage mailMessage = null;
			AlternateView alternateView = null;
			SmtpClient smtpClient = null;
			MailAddress[] mailAddressesFROM, mailAddressesTO, mailAddressesCC, mailAddressesBCC;

			if (mail.to == null) throw new Exception("No se especificó destinatario.");
			if (mail.subject == null) throw new Exception("No se especificó subject.");
			if (mail.body == null) throw new Exception("No se especificó body.");
			if (mail.body.Length >= 10 && mail.body.Substring(0, 10) == "MailError:") throw new Exception(mail.body);

			if (mail.from == null) mail.from = SMTP.defaultFrom;
			if (mail.password == null) mail.password = SMTP.defaultPassword;

			mailAddressesFROM = ParseEmailAddresses(mail.from);
			mailAddressesTO = ParseEmailAddresses(mail.to);
			mailAddressesCC = ParseEmailAddresses(mail.cc);
			mailAddressesBCC = ParseEmailAddresses(mail.bcc);


			mailMessage = new MailMessage(mailAddressesFROM[0], mailAddressesTO[0]);
			if (mailAddressesTO.Length > 1) for (int i = 1; i < mailAddressesTO.Length; i++) mailMessage.To.Add(mailAddressesTO[i]);
			if (mailAddressesCC != null) foreach (MailAddress mailAddress in mailAddressesCC) mailMessage.CC.Add(mailAddress);
			if (mailAddressesBCC != null) foreach (MailAddress mailAddress in mailAddressesBCC) mailMessage.Bcc.Add(mailAddress);

			mailMessage.Subject = mail.subject;
			mailMessage.Body = mail.body;

			if (mail.isHTML) alternateView = AlternateView.CreateAlternateViewFromString(mail.body, System.Text.Encoding.UTF8, "text/html");
			else alternateView = AlternateView.CreateAlternateViewFromString(mail.body, System.Text.Encoding.UTF8, "text/plain");
			mailMessage.AlternateViews.Add(alternateView);

			if (mail.attachments != null)
				foreach (Files.File file in Files.Read(mail.idsesion, mail.attachments, null, null))
				{
					Attachment attachment = new Attachment(new MemoryStream(file.data), file.name, file.ctype);
					mailMessage.Attachments.Add(attachment);
				}

			smtpClient = new SmtpClient();
			smtpClient.Host = SMTP.host;
			smtpClient.Port = SMTP.port;
			smtpClient.DeliveryMethod = SmtpDeliveryMethod.Network;
			smtpClient.Credentials = new System.Net.NetworkCredential(mail.from, mail.password);
			smtpClient.EnableSsl = false;
			smtpClient.Send(mailMessage);
		}
	}
}
