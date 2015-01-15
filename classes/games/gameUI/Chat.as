package games.gameUI 
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import playerio.Connection;
	/**
	 * ...
	 * @author Alexey Kuznetsov
	 */
	public final class Chat extends MovieClipContainer
	{
		private const _defaultInputWidth:int = 120;
		private var _players:Array;
		private var _connection:Connection;
		private var _scrollState:String = "none";
		private var scrolling:Boolean = false;
		private var _bounds:Rectangle;		
		private var _badWords:Array = ["ahole", "anus", "ash0le", "ash0les", "asholes", "ass", "Ass Monkey", "Assface", "assh0le", "assh0lez", "asshole", "assholes", "assholz", "asswipe", "azzhole", "bassterds", "bastard", "bastards", "bastardz", "basterds", "basterdz", "Biatch", "bitch", "bitches", "Blow Job", "boffing", "butthole", "buttwipe", "c0ck", "c0cks", "c0k", "Carpet Muncher", "cawk", "cawks", "Clit", "cnts", "cntz", "cock", "cockhead", "cock-head", "cocks", "CockSucker", "cock-sucker", "crap", "cum", "cunt", "cunts", "cuntz", "dick", "dild0", "dild0s", "dildo", "dildos", "dilld0", "dilld0s", "dominatricks", "dominatrics", "dominatrix", "dyke", "enema", "f u c k", "f u c k e r", "fag", "fag1t", "faget", "fagg1t", "faggit", "faggot", "fagit", "fags", "fagz", "faig", "faigs", "fart", "flipping the bird", "fuck", "fucker", "fuckin", "fucking", "fucks", "Fudge Packer", "fuk", "Fukah", "Fuken", "fuker", "Fukin", "Fukk", "Fukkah", "Fukken", "Fukker", "Fukkin", "g00k", "gay", "gayboy", "gaygirl", "gays", "gayz", "God-damned", "h00r", "h0ar", "h0re", "hells", "hoar", "hoor", "hoore", "jackoff", "jap", "japs", "jerk-off", "jisim", "jiss", "jizm", "jizz", "knob", "knobs", "knobz", "kunt", "kunts", "kuntz", "Lesbian", "Lezzian", "Lipshits", "Lipshitz", "masochist", "masokist", "massterbait", "masstrbait", "masstrbate", "masterbaiter", "masterbate", "masterbates", "Motha Fucker", "Motha Fuker", "Motha Fukkah", "Motha Fukker", "Mother Fucker", "Mother Fukah", "Mother Fuker", "Mother Fukkah", "Mother Fukker", "mother-fucker", "Mutha Fucker", "Mutha Fukah", "Mutha Fuker", "Mutha Fukkah", "Mutha Fukker", "n1gr", "nastt", "nigger;", "nigur;", "niiger;", "niigr;", "orafis", "orgasim;", "orgasm", "orgasum", "oriface", "orifice", "orifiss", "packi", "packie", "packy", "paki", "pakie", "paky", "pecker", "peeenus", "peeenusss", "peenus", "peinus", "pen1s", "penas", "penis", "penis-breath", "penus", "penuus", "Phuc", "Phuck", "Phuk", "Phuker", "Phukker", "polac", "polack", "polak", "Poonani", "pr1c", "pr1ck", "pr1k", "pusse", "pussee", "pussy", "puuke", "puuker", "queer", "queers", "queerz", "qweers", "qweerz", "qweir", "recktum", "rectum", "retard", "sadist", "scank", "schlong", "screwing", "semen", "sex", "sexy", "Sh!t", "sh1t", "sh1ter", "sh1ts", "sh1tter", "sh1tz", "shit", "shits", "shitter", "Shitty", "Shity", "shitz", "Shyt", "Shyte", "Shytty", "Shyty", "skanck", "skank", "skankee", "skankey", "skanks", "Skanky", "slut", "sluts", "Slutty", "slutz", "son-of-a-bitch", "tit", "turd", "va1jina", "vag1na", "vagiina", "vagina", "vaj1na", "vajina", "vullva", "vulva", "w0p", "wh00r", "wh0re", "whore", "xrated", "xxx", "b!+ch", "bitch", "blowjob", "clit", "arschloch", "fuck", "shit", "ass", "asshole", "b!tch", "b17ch", "b1tch", "bastard", "bi+ch", "boiolas", "buceta", "c0ck", "cawk", "chink", "cipa", "clits", "cock", "cum", "cunt", "dildo", "dirsa", "ejakulate", "fatass", "fcuk", "fuk", "fux0r", "hoer", "hore", "jism", "kawk", "l3itch", "l3i+ch", "lesbian", "masturbate", "masterbat*", "masterbat3", "motherfucker", "s.o.b.", "mofo", "nazi", "nigga", "nigger", "nutsack", "phuck", "pimpis", "pusse", "pussy", "scrotum", "sh!t", "shemale", "shi+", "sh!+", "slut", "smut", "teets", "tits", "boobs", "b00bs", "teez", "testical", "testicle", "titt", "w00se", "jackoff", "wank", "whoar", "whore", "*damn", "*dyke", "*fuck*", "*shit*", "@$$", "amcik", "andskota", "arse*", "assrammer", "ayir", "bi7ch", "bitch*", "bollock*", "breasts", "butt-pirate", "cabron", "cazzo", "chraa", "chuj", "Cock*", "cunt*", "d4mn", "daygo", "dego", "dick*", "dike*", "dupa", "dziwka", "ejackulate", "Ekrem*", "Ekto", "enculer", "faen", "fag*", "fanculo", "fanny", "feces", "feg", "Felcher", "ficken", "fitt*", "Flikker", "foreskin", "Fotze", "Fu(*", "fuk*", "futkretzn", "gay", "gook", "guiena", "h0r", "h4x0r", "hell", "helvete", "hoer*", "honkey", "Huevon", "hui", "injun", "jizz", "kanker*", "kike", "klootzak", "kraut", "knulle", "kuk", "kuksuger", "Kurac", "kurwa", "kusi*", "kyrpa*", "lesbo", "mamhoon", "masturbat*", "merd*", "mibun", "monkleigh", "mouliewop", "muie", "mulkku", "muschi", "nazis", "nepesaurio", "nigger*", "orospu", "paska*", "perse", "picka", "pierdol*", "pillu*", "pimmel", "piss*", "pizda", "poontsee", "poop", "porn", "p0rn", "pr0n", "preteen", "pula", "pule", "puta", "puto", "qahbeh", "queef*", "rautenberg", "schaffer", "scheiss*", "schlampe", "schmuck", "screw", "sh!t*", "sharmuta", "sharmute", "shipal", "shiz", "skribz", "skurwysyn", "sphencter", "spic", "spierdalaj", "splooge", "suka", "b00b*", "testicle*", "titt*", "twat", "vittu", "wank*", "wetback*", "wichser", "wop*", "yed", "zabourah", "pizdec", "hui", "suka", "nahui", "eblan", "muduck", "eblan", "anal", "suchka", "bleat", "bleat'",
		"пидар", "мудак", "чмо", "дибил", "говно", "дерьмо", "тварь", "еблан", "уебашка", "уебатор", "мудила", "пидрила", "мудак", "гавноеб", "ебан", "ебать","хер", "пизда", "хуй", "йух", "блять", "блеать", "блиать", "блядь", "блядина", "говноеб", "уебище", "пиздопроебище", "пиздец", "на хуй", "придурок", "пизда", "пизду", "пизде", "пиздеть", "членосос", "хуесос", "анал", "хуйло", "хуило", "ахуел", "иди на хуй", "иди нахуй", "нахер", "иди впизду", "ебалан", "4мо", "сученок", "сучара","гнида", "ебал в рот", "ебал врот", "ебаный", "ебаная", "ебаный", "ебанный ", "хуйня", "жуйня", "охуел", "охуевший", "3.14здец", "херня", "по хуй", "похуй", "ебись","придурок", "пидофил", "педофил", "мудоеб", "ёбырь", "ебантяй", "сучка", "дура", "дегенерат", "ебучий"];		
		
		public function Chat(players:Array, connection:Connection) 
		{
			super(new chat(), 9, 536);
			_connection = connection;
			_players = players;
			
			_mc.chat_mc.addEventListener(MouseEvent.CLICK, showCloseChat);
			_mc.bar_mc.bg.send_btn.addEventListener(MouseEvent.CLICK, sendMessage);
			
			_mc.history_mc.bg.visible = false;
			_mc.bar_mc.visible = false;
			_mc.history_mc.bg.line_mc.visible = false;
			_mc.history_mc.bg.scrollMC.visible = false;
			
			_mc.bar_mc.input_txt.text = "";
			_mc.bar_mc.input_txt.addEventListener(Event.CHANGE, adjustInputWidth);
			_mc.history_mc.history_txt.text = "";			
			
			_mc.bar_mc.input_txt.addEventListener(KeyboardEvent.KEY_DOWN, trySendByEnter);
			_mc.bar_mc.input_txt.addEventListener(KeyboardEvent.KEY_DOWN, trySendByEnter, true);
			
			addEventListener(Event.ENTER_FRAME, tryScroll);
			
			_bounds = new Rectangle(_mc.history_mc.bg.line_mc.x, _mc.history_mc.bg.line_mc.y, 0, _mc.history_mc.bg.line_mc.height);
			
			_mc.history_mc.bg.scrollMC.addEventListener (MouseEvent.MOUSE_DOWN, startScroll);
			Networking.client.stage.addEventListener (MouseEvent.MOUSE_UP, stopScroll);
		}
		
		private function adjustInputWidth(e:Event = null):void 
		{
			var difference:int = _mc.bar_mc.input_txt.textWidth - _defaultInputWidth + 25;  //242 actually. but 30px is good to leave
			if (difference > 0) 
			{				
				if((_mc.bar_mc.input_txt.width + difference) < 1200) _mc.bar_mc.input_txt.width = _defaultInputWidth + difference;
			}
			else _mc.bar_mc.input_txt.width = _defaultInputWidth;
			
			_mc.bar_mc.bg.mask_mc.width = _mc.bar_mc.input_txt.width + 25; //14 - difference b/w mask width & textfield width	
			_mc.bar_mc.bg.send_btn.x = _mc.bar_mc.bg.mask_mc.width;
		}
		
		private function startScroll (e:Event):void
		{
			scrolling = true;
			_mc.history_mc.bg.scrollMC.startDrag (false, _bounds);
		}
		
		private function stopScroll (e:Event):void 
		{
			scrolling = false;
			_mc.history_mc.bg.scrollMC.stopDrag ();
		} 
		
		private function tryScroll(e:Event):void 
		{
			if (scrolling) _mc.history_mc.history_txt.pixelScrollV = Math.round(((_mc.history_mc.bg.scrollMC.y - _bounds.y) / _mc.history_mc.bg.line_mc.height) * _mc.history_mc.history_txt.textHeight);	
		}
		
		private function trySendByEnter(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.ENTER) sendMessage();
		}
		
		private function sendMessage(e:MouseEvent = null):void 
		{	
			var inputForCheck:String = _mc.bar_mc.input_txt.text.toLowerCase();
			var badWord:String = "";
			for each (var word:String in _badWords) if (inputForCheck.indexOf(word) != -1) badWord = word; 
			
			if (_mc.bar_mc.input_txt.text.length > 0 && badWord == "") 
			{
				addMessage(UserData.id, _mc.bar_mc.input_txt.text);			
				_connection.send("ch", _mc.bar_mc.input_txt.text);				
			}
			
			if (badWord != "") _mc.bar_mc.input_txt.text = '"' + badWord + '" ' + Lingvo.dictionary.badword();
			else 
			{
				_mc.bar_mc.input_txt.text = "";										
			}	
			adjustInputWidth();		
		}
		
		public function addMessage(guyID:String, message:String):void
		{			
			var guyName:String; 
			if (guyID == UserData.id) guyName = UserData.name;
			else for (var i:int = 0; i < _players.length; i++) if (_players[i].id == guyID) guyName = _players[i].name;
			
			var guysColor:uint = 0;
			for each (var guy:Object in _players) { if (guy.id == guyID) guysColor = guy.color };
			
			_mc.history_mc.history_txt.htmlText += '<font color="#' + Misc.POSSIBLE_COLORS[guysColor].toString(16) + '">' + guyName + ": " + '</font>' + message; //html 4 name-colorising
			
			if (_mc.history_mc.history_txt.maxScrollV > 0)
			{
				_mc.history_mc.bg.line_mc.visible = true;
				_mc.history_mc.bg.scrollMC.visible = true;				
			}
			
			_mc.history_mc.history_txt.scrollV = _mc.history_mc.history_txt.maxScrollV - 1; // SENT msg always visible.
			_mc.history_mc.bg.scrollMC.y = _mc.history_mc.bg.line_mc.y + _mc.history_mc.bg.line_mc.height;
		}
		
		private function showCloseChat(e:MouseEvent):void 
		{
			_mc.history_mc.bg.visible = _mc.history_mc.bg.visible?false:true;
			_mc.bar_mc.visible = _mc.bar_mc.visible?false:true;
			_mc.history_mc.history_txt.selectable = _mc.bar_mc.visible;
		}		
	}
}