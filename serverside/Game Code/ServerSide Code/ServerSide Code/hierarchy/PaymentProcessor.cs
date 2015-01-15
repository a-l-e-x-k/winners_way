using System;
using System.Collections.Generic;
using PlayerIO.GameLibrary;

namespace ServerSide
{
	/*
	 * Handles payments, adds bought items to user's vault.
	 */
	public abstract class PaymentProcessor : Game<Player>
	{
		protected void BuySinglePowerups(Player player, Message message)
		{
			var totalPrice = Data.PowerupPrices[message.GetString(0)] * message.GetInt(1); //amount * price
			Console.WriteLine("buySinglePowerups. totalPrice: " + totalPrice);
			player.PayVault.Refresh(delegate
			{
				if (player.PayVault.Coins >= totalPrice)
				{
					var allItems = new BuyItemInfo[message.GetInt(1)]; //array for item's amount
					for (var i = 0; i < message.GetInt(1); i++)
					{
						allItems[i] = new BuyItemInfo(message.GetString(0));
					}
					BuyItems(allItems, player);
				}
				else player.Send("buyne", player.PayVault.Coins);
			});
		}

		protected void BuyInfinity(Player player, Message message)
		{
			Console.WriteLine(message);
			var infinityDays = Data.GetInfinityData(message.GetInt(0))[0]; //infinity type (index), gameIndex
			var infinityPrice = Data.GetInfinityData(message.GetInt(0))[1];
			Console.WriteLine("infinityHours: " + infinityDays);
			Console.WriteLine("infinityPrice: " + infinityPrice);
			player.PayVault.Refresh(delegate
			{
				if (player.PayVault.Coins >= infinityPrice)
				{
					var secondsNow = Math.Round((DateTime.UtcNow - new DateTime(1970, 1, 1, 0, 0, 0)).TotalSeconds);
					Console.WriteLine("secondsNow: " + secondsNow);
					var secondsToAdd = infinityDays * 24 * 60 * 60;
					var infinityExpires = secondsNow + secondsToAdd;
					Console.WriteLine("infinityExpires: " + infinityExpires);

					BuyItemInfo[] infinityItem = { new BuyItemInfo("infinity" + infinityDays).Set("expires", (uint)infinityExpires) };
					BuyItems(infinityItem, player);
				}
				else player.Send("buyne", player.PayVault.Coins);
			});

		}

		protected void BuyPowerupsPack(Player player, Message message) //message(0) - index of pack. message(1) - index of game
		{
			var ofEach = Data.GetPackData(message.GetInt(0))[0];
			var packPrice = Data.GetPackData(message.GetInt(0))[1];

			Console.WriteLine("buyPowerupsPack: offerPrice: " + packPrice);
			Console.WriteLine("buyPowerupsPack: packAmount: " + ofEach);
			player.PayVault.Refresh(delegate
			{
				if (player.PayVault.Coins >= packPrice) //offerPrice > 0 -> so if dude substituted offer thingy for smth crazy -> error wi
				{
					var allItems = new BuyItemInfo[ofEach * Data.PowerupNames.Length]; //array for item's amount
					for (var i = 0; i < ofEach; i++)
					{
						for (var j = 0; j < Data.PowerupNames.Length; j++)
						{
							allItems[i * Data.PowerupNames.Length + j] = new BuyItemInfo(Data.PowerupNames[j]);
							Console.WriteLine("adding: " + Data.PowerupNames[j]);
						}
					}

					player.PayVault.Buy(false, new[] { new BuyItemInfo("pack" + ofEach) }, null, HandleError); //just for statistics. Item that costs 0. E.g. "snakePack5x"

					player.PayVault.Give(allItems,
					    () => player.Send("buyok", player.PayVault.Coins),
					delegate(PlayerIOError error)
					{
						Console.WriteLine(error);
						player.Send("payerr");
					});
				}
				else player.Send("buyne", player.PayVault.Coins);
			});
		}

		private static void BuyItems(IList<BuyItemInfo> items, BasePlayer player)
		{
			const int maxPerRound = 20; //max items bought per payvault.Buy call will be 20. Because at large amounts it throws an error
			var amount = items.Count > 19 ? 20 : items.Count;
			var oneRound = new BuyItemInfo[amount];
			var nextRoundItems = new BuyItemInfo[items.Count - amount]; //if > 20 then this array will be filled with items for next calls

			for (var i = 0; i < amount; i++)
			{
				oneRound[i] = items[i];
			}

			if (items.Count > maxPerRound)
			{
				nextRoundItems = new BuyItemInfo[items.Count - amount];
				for (var i = 0; i < items.Count - maxPerRound; i++)
				{
					nextRoundItems[i] = items[i + maxPerRound];
				}

				Console.WriteLine("newItems.length: " + nextRoundItems.Length);
			}

			player.PayVault.Buy(true, oneRound,
			delegate
			{
				if (nextRoundItems.Length > 0) BuyItems(nextRoundItems, player);
				else player.Send("buyok", player.PayVault.Coins);
			},
			    error => {
			        Console.WriteLine(error);
			        player.Send("payerr");
			    });
		}

		public override void UserJoined(Player player) { }
		public void HandleError(PlayerIOError error) { throw error; }
		public override void GameStarted() { }
		public override void UserLeft(Player player) { }
		public override void GameClosed() { }
		public override void GotMessage(Player player, Message message) { }
	}
}
