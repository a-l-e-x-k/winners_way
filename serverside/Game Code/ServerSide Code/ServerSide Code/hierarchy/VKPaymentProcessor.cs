using System;
using System.Collections.Generic;
using System.Globalization;
using System.Security.Cryptography;
using System.Xml;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	/*
	 * Handles VK payments, balance change.
	 */
	public abstract class VKPaymentProcessor : PaymentProcessor
	{
		public Random Rand = new Random();

		protected void GetBalance(Player player, Message message)
		{
			Console.WriteLine(message.GetString(0)); //auth_key
			var amountToWithdraw = message.GetInt(1);
			Console.WriteLine("toWithdraw: " + amountToWithdraw);

			var uid = player.ConnectUserId;
			const string apiSecret = "8TXYEgT44V50Ul3KURV6";
			const string apiID = "2781528";
			const string methodName = "secure.getBalance";
			const string version = "3.0";
			var timestamp = (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds.ToString(CultureInfo.InvariantCulture);
			var random = Rand.Next(100000).ToString(CultureInfo.InvariantCulture);

			var trueAuthKey = MD5(apiID + '_' + uid + '_' + apiSecret);
			if (trueAuthKey == message.GetString(0))
			{
				var sig = MD5("api_id=" + apiID + "method=" + methodName + "random=" + random + "timestamp=" + timestamp + "uid=" + uid + "v=" + version + apiSecret);
				Console.WriteLine(sig);

				var request = new Dictionary<string, string>();
				request["api_id"] = apiID;
				request["method"] = methodName;
				request["random"] = random;
				request["sig"] = sig;
				request["timestamp"] = timestamp;
				request["uid"] = uid;
				request["v"] = version;
				PlayerIO.Web.Post("http://api.vk.com/api.php", request, resp => TryWithdraw(resp, amountToWithdraw, player), HandleError);
			}
			else player.Send("err");
			Console.WriteLine("trueAuthKey: " + trueAuthKey);
		}

		private void TryWithdraw(HttpResponse response, int toWithdraw, Player player)
		{
			var balance = 0;

			var reader = new XmlTextReader(response.ResponseStream) {WhitespaceHandling = WhitespaceHandling.Significant};

		    while (reader.Read())
			{
				Console.WriteLine("{0}: {1}", reader.NodeType, reader.Name);
				Console.WriteLine("reader.valuetype: " + reader.ValueType);
				if (reader.NodeType.ToString() == "Text") balance = Convert.ToInt32(reader.Value) / 100;
			}

			Console.WriteLine("balance: " + balance);

			if (toWithdraw > balance) player.Send("notEnough", toWithdraw - balance); //send how much is not enough
			else
			{
				uint coinsToAdd = 0;
				switch (balance)
				{
				    case 3:
				        coinsToAdd = 300;
				        break;
				    case 5:
				        coinsToAdd = 600;
				        break;
				    case 10:
				        coinsToAdd = 1250;
				        break;
				    case 20:
				        coinsToAdd = 2600;
				        break;
				    case 50:
				        coinsToAdd = 6600;
				        break;
				    case 100:
				        coinsToAdd = 14000;
				        break;
				    default:
				        player.Send("err");
				        break;
				}

			    if (coinsToAdd == 0) return;
			    Console.WriteLine("gonna credit with : " + coinsToAdd);
			    player.PayVault.Credit(coinsToAdd, "paidVK", null, HandleError);
			    player.Send("ok", coinsToAdd);
			    WithdrawVotes(player, balance);
			}
		}

		private void WithdrawVotes(BasePlayer player, int amount)
		{
			var uid = player.ConnectUserId;
			const string apiSecret = "8TXYEgT44V50Ul3KURV6";
			const string apiID = "2781528";
			const string methodName = "secure.withdrawVotes";
			const string version = "3.0";
			var timestamp = (DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds.ToString(CultureInfo.InvariantCulture);
			var random = Rand.Next(100000).ToString(CultureInfo.InvariantCulture);
			var votes = (amount * 100).ToString(CultureInfo.InvariantCulture);

			var sig = MD5("api_id=" + apiID + "method=" + methodName + "random=" + random + "timestamp=" + timestamp + "uid=" + uid + "v=" + version + "votes=" + votes + apiSecret);
			Console.WriteLine(sig);

			var request = new Dictionary<string, string>();
			request["api_id"] = apiID;
			request["method"] = methodName;
			request["random"] = random;
			request["sig"] = sig;
			request["timestamp"] = timestamp;
			request["uid"] = uid;
			request["v"] = version;
			request["votes"] = votes;
			PlayerIO.Web.Post("http://api.vk.com/api.php", request, response => Console.WriteLine("Votes withdrawn!"), HandleError);
		}

		public string MD5(string password)
		{
			var textBytes = System.Text.Encoding.UTF8.GetBytes(password);
		    var cryptHandler = new MD5CryptoServiceProvider();
		    var hash = cryptHandler.ComputeHash(textBytes);
		    var ret = "";
		    foreach (byte a in hash)
		    {
		        if (a < 16)
		            ret += "0" + a.ToString("x");
		        else
		            ret += a.ToString("x");
		    }
		    return ret;
		}

		protected void SendNotifications(string ids, Player creator)
		{
			const string apiSecret = "8TXYEgT44V50Ul3KURV6";
			const string apiID = "2781528";

			const string message = "В честь праздника каждому зашедшему до 11 марта дарим 33 усилялки (по 3 каждого типа)! Приятных выходных!";
			Console.WriteLine(message);

			const string methodName = "secure.sendNotification";
			const string version = "3.0";
			var timestamp = ((int)(DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds).ToString(CultureInfo.InvariantCulture);
			var random = Rand.Next(100000).ToString(CultureInfo.InvariantCulture);

			var sig = MD5("api_id=" + apiID + "message=" + message + "method=" + methodName + "random=" + random + "timestamp=" + timestamp + "uids=" + ids + "v=" + version + apiSecret);

			var request = new Dictionary<string, string>();
			request["api_id"] = apiID;
			request["message"] = message;
			request["method"] = methodName;
			request["random"] = random;
			request["sig"] = sig;
			request["timestamp"] = timestamp;
			request["uids"] = ids;
			request["v"] = version;
			PlayerIO.Web.Post("http://api.vk.com/api.php", request,
			    response => creator.Send("nots", response.Text, response.StatusCode), HandleError);			
		}
	}
}
