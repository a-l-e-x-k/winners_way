package languages 
{
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public class Russian implements ILanguage
	{
		public const LANGUAGE:String = "RUS";
		
		public function play():String { return("Играть"); };
		public function jackpot():String { return("Джекпот");}
		public function mypowerups():String { return("Мои усилялки"); }
		public function infinityExpires():String { return("Безлимитки осталось на:\n"); };
		public function win():String { return("выиграй");}
		public function more():String { return("еще");}
		public function time():String { return("раз");}
		public function time2():String { return("раза");}
		public function toUnlock():String { return("чтобы открыть"); }
		public function d():String { return("д"); };
		public function h():String { return("ч");}
		public function m():String { return("м");}
		public function coins():String { return("монет");}
		public function ago():String { return("назад");}
		public function beforeFinish():String { return("До конца игры:");}
		public function beforeFinishStackup():String { return("Секунд осталось:"); }
		public function intro():String { return('Просто нажми "Играть"... :)');}
        public function flower():String { return('цветок');}
		
		public function connecting():String { return("Соединение...");}
		public function loading():String { return("Загрузка...");}
		public function findingopponent():String { return("Поиск соперника..."); }
		public function awaitingFriend():String { return("Ждём друга..."); };
		public function connectingToFriend():String { return("Идём к другу..."); };
		
		public function notenough():String { return("Недостаточно монет.");}
		public function cancel():String { return("Отмена");}
		public function addCoins():String { return("Добавить");}
		public function success():String { return("Покупка успешна!");}
		public function add():String { return("Магазин");}
		
		public function toWinjp():String { return("Чтобы выиграть джекпот, победи 8 разных людей подряд.");}
		public function descriptionJp():String { return("Каждый раз, когда кто-то играет в игру мы добавляем немножко монет в джекпот. Сколько мы добавляем зависит от того, сколько усилялок было использовано за игру. Т.е. чем больше ты используешь усилялок, тем больше и вкуснее будет общий приз.");}
		
		public function st1():String { return("Составляй фигуры друг на друга");}
		public function st2():String { return("Если что-то упадет в твой ход - ты проиграешь");}
		public function st3():String { return('Смена хода - только если фигуры <font color = "#CC0000">не шатаются</font>');}
		public function st4():String { return("Используй усилялки, чтобы спасти свой ход");}
		
		public function sn1():String { return("Ешь фрукты");}
		public function sn2():String { return('<font color = "#CC0000">Не</font> ешь себя');}
		public function sn3():String { return("Самый длинный выиграет");}
		
		public function reeling():String { return("Фигуры шатаются.\nЭто плохо.");}
		public function asyncError():String { return("Упс. Ошибочка. Она не затронет ваш прогресс в игре.");}
		public function yourTurn():String { return("Твой ход!");}
		public function turnOf():String { return("Ходит");}	
		
		public function ty():String { return("Спасибо!");}
		public function giveaway():String { return("Усилялки в подарок");}
		
		public function powerTut1():String { return("Давай используем усилялку.\n\nНажми " + '"1"' + " на клавиатуре, чтобы использовать первую усилялку.");}
		public function powerTut2():String { return("И давай попробуем вторую усилялку.\n\nДогадайся, какую цифру нужно нажать, чтобы использовать усилялку номер *два*...");}
		public function firstStreak():String { return("Этот цветок - цепочка из двух побед: \n\n\n\n\n\n\nТебе надо победить двух людей ПОДРЯД, чтобы пройти его. \nЕсли ты проиграешь, не завершив цепочку, то придется начать её заново.");}
		public function jptut():String { return("Ура! Вы открыли джекпот и теперь можете выиграть его!\n\nДля этого нужно победить 8 человек подряд.\n\nЕсли вы проиграете, то придется начать цепочку заново.\n\nЖелаем удачи!");}
		public function gofull():String { return("Пойдем посмотрим всю тропу :)");}
		public function spiraltut():String { return('Поздравляем, вы открыли "Спираль побед"!\n\nОна содержит всех людей, которых вы победили (в любой игре).\n\nПосмотри, у тебя уже есть несколько людей там!');}		
		public function sutut():String { return("Перетащи матрас на лежак");}
		public function wstut():String { return("В этой игре нужно найти слова на поле.\n\nОни могут быть написаны вертикально и горизонатально (слева направо и сверху вниз).\n\n\n                         Вот первое:\nВыдели его мышкой (как ты выделяешь текст)"); }
		public function tryOtherGames():String { return('Lets try out other games!\nSelect any game and click "Play" after that.'); };
		public function wtfstory1():String { return("Давай посмотрим всю тропу!");}
		public function wtfstory2_1():String { return('"Тропа" - это новый тип уровней.\nЧто ты видишь - это маленький кусочек большой тропы. Всё впереди!'); }
		public function wtfstory2_2_1():String { return("Каждый раз, когда ты побеждаешь кого-то, он(она) будет добавлен(а) сюда."); }
		public function wtfstory2_2_2():String { return('Наполни свой "Путь" победами!');}
		public function cool():String { return("Круто!");}
		
		public function wtf():String { return("Спрятавшиеся слова: ");}
		public function friends():String { return("Мои друзья");}
		public function toplabel():String { return("Топ 100");}		
		
		public function shopname():String { return("Магазин");}
		public function buy():String { return("Купить!"); }
		public function inpacks():String { return("Усилялки оптом"); };
		public function unlimitedpowerups():String { return("Безлимитки на усилялки"); };
		public function forAllGames():String { return("(действуют на все игры)"); };
		
		public function mystory():String { return("Моя тропа");}
		public function nextlevel():String { return("След. уровень");}
		public function forwardlevel():String { return("Пред. уровень");}
		
		public function myspiral():String { return("Cпираль побед");}
		public function streakcolors():String { return("Цвета цепочек");}
		public function andmore():String { return("(и более)");}	
		
		public function everywon():String { return("Все выиграли!");}
		public function youwon():String { return("Вы выиграли!");}
		public function wongame():String { return("- победитель!");}
		public function showfull():String { return("Вся тропа");}
		public function postit():String { return("На стену");}
		public function toalbum():String { return("В альбом"); }		
		public function existsAlready():String { return("уже есть в вашей тропе"); };
		
		public function coinlogo():String { return("Добавить монет");}
		public function votes():String { return("Голоса");}
		public function coinsname():String { return("Монеты");}
		
		public function invite():String { return("Пригласить");}
		public function invitetext():String { return("Приглашаю тебя сыграть в аркады в реальном времени c реальными людьми! Это чертовски необычно!");}
		public function uploadingphotos():String { return("Загружаем фото...");}
		public function superText():String { return("Всё отлично :)");}		
		public function error():String { return("Ошибка платежа.");}
		
		public function superbtn():String { return("Супер!");}
		public function youwonjp():String { return("Вы выиграли");}
		
		public function gotcha():String { return("Понятно!");}
		public function justnow():String { return("только что");}
		
		public function usilyalok():String { return("усилялок");}
		public function buying():String { return("Покупка...");}		
		public function payerr():String { return("Ошибка платежа.");}
		
		public function badword():String { return(" - это плохое слово. Не надо его использовать :)");}
		public function urn():String { return("од");}
		
		public function dragme():String { return("Перетащи меня");}
		
		public function uploaderror():String { return("Ошибка загрузки");}
		public function mygamewith():String { return("Моя игра с");}
		public function inwinnersway():String { return('в "Winner' + "'s Way " + "(Тропе побед)");}
		public function saveit():String { return("Сохранить!");}		
		public function ok():String { return("Окей!");}
		public function completed():String { return("пройдено");}
		public function of():String { return("из");}
		public function completedExcl():String { return("Пройдено!");}
		
		public function post():String { return("Окей");}
		public function permissionsgranted():String { return("Настройки изменены"); }	
		
		public function playWithAnyone():String { return("Играть с кем угодно"); };
		public function playWithFriend():String { return("Играть с другом"); };
		public function playWithFriendHeader():String { return("Отправьте эту ссылку другу. Игра начнется, когда он перейдет по ней."); };
		public function playWithFriendNote():String { return("Заметьте, что это разовое действие, и после того, как вы с другом начнете играть, начало новой или смена игры будет происходить в 1 клик."); };
		public function playAgain():String { return("Играть еще"); };
		
		public function encourageInviting():String { return "Мы хотим добавить новые игры и форматы игр (турниры на 16, 32 чел.). Но не можем этого сделать из-за малого числа игроков (Вам не с кем будет играть). Помогите нам сделать это приложение более интересным!" }
		public function helpInvite():String { return "Я помогу (приглашу друзей)" };
		public function wontHelpInvite():String { return "Не буду помогать" };
		
		public function getWinMore(quantity:int):String
		{
			var times:String = "";			
			if (quantity == 2 || quantity == 3 || quantity == 4 || quantity == 22 || quantity == 23 || quantity == 24 || quantity == 33 || quantity == 34 || quantity == 35) times = "разa";
			else times = "раз";				
			return "победи еще " + quantity.toString() + " " + times + ", чтобы открыть";			
		}
		
		public function getPowerupFullName(shortName:String):String
		{
			var fullName:String = "";			
			if (shortName == "firstLetter") fullName = "Первая буква";
			else if (shortName == "removeLetters") fullName = "-20 букв";
			else if (shortName == "boost2x") fullName = "2x Ускоритель";
			else if (shortName == "boost3x") fullName = "3x Ускоритель";
			else if (shortName == "missile") fullName = "Самонаводящаяся ракета";
			else if (shortName == "sevenMines") fullName = "Семь мин";
			else if (shortName == "grid") fullName = "Показать сетку";
			else if (shortName == "swapShape") fullName = "Сменить фигуру";
			else if (shortName == "nanoShape") fullName = "Мини-рубинчик";
			else if (shortName == "undo") fullName = "Отменить ход";
			else if (shortName == "flyingbar") fullName = "Летающая панель";			
			return fullName;			
		}
		
		public function getPowerupDescription(powerupName:String):String
		{
			var description:String = "";			
			if (powerupName == "firstLetter") description = "Я покажу тебе первую букву случайного слова из списка.";
			else if (powerupName == "removeLetters") description = "Я уберу 20 случайных букв, которые не входят ни в одно слово.";
			else if (powerupName == "boost2x") description = "Я ускорю твою змейку в 2 раза на 7 секунд.";
			else if (powerupName == "boost3x") description = "Я ускорю твою змейку в 3 раза на 7 секунд.";
			else if (powerupName == "missile") description = "Я запущу самонаводяющуюся ракету (нокаутирует соперника на 7 секунд).";
			else if (powerupName == "sevenMines") description = "Я подложу 7 мин для твоего противника (безопасных для тебя).";
			else if (powerupName == "grid") description = "Я покажу тебе вспомогательную сетку.";
			else if (powerupName == "swapShape") description = "Я сменю текущую фигуру (которую тебе надо тащить).";
			else if (powerupName == "nanoShape") description = "Я дам тебе микро-рубинчик, который можно поместить куда угодно.";
			else if (powerupName == "undo") description = "Я уберу последнюю фигуру, которую поставил твой противник.";
			else if (powerupName == "flyingbar") description = "Я создам летающую панель, на которую можно ставить фигуры.";			
			return description;			
		}
		
		public function getWon(sex:int):String
		{
			return (sex == 1 ? "выиграла" : "выиграл");
		}		
		
		public function getInfinityText(duration:int):String
		{
			var result:String = "";
			if (duration == 1) result = "На 1 день";
			else if (duration == 3) result = "На 3 дня";
			else if (duration == 7) result = "На 7 дней";
			else if (duration == 30) result = "На 30 дней";			
			return result;
		}
	}
}