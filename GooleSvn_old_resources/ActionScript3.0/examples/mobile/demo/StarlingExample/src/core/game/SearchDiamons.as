package core.game
{
	import core.game.resource.Diamonds;
	
	/**
	 * 说明：SearchDiamons 搜索指定条件的消除的所有钻石方法
	 * @author Victor
	 * @email acsh_ysj@163.com
	 * 2012-2-20
	 */
	
	public class SearchDiamons
	{
		
		/////////////////////////////////static ////////////////////////////
		
		
		
		///////////////////////////////// vars /////////////////////////////////
		
		
		
		public function SearchDiamons()
		{
		}
		
		/////////////////////////////////////////public /////////////////////////////////
		
		
		
		/////////////////////////////////////////static ///////////////////////////////
		
		/**
		 * 此方法作用在于原子爆破块搜索；
		 * @param $targetArr 指定搜索的目标数组
		 * @param card 当前点击的钻石或道具对象
		 * @return Array
		 * 
		 */
		static public function findAtomCard($targetArr:Array, $card:Diamonds):Vector.<Diamonds>
		{
			var closeArr:Vector.<Diamonds> = new Vector.<Diamonds>();
			var xCoor:int = $card.rows;
			var yCoor:int = $card.cols;
			var rows:int = DispelMainType.ROWS;
			var cols:int = DispelMainType.COLS;
			$card.visible = true;
			closeArr.push($card);
			for (var i:int=0; i < rows; i++)
			{
				for (var j:int=0; j < cols; j++)
				{
					if (Math.pow((xCoor - i), 2) + Math.pow((yCoor - j), 2) <= 9)
					{
						var card:Diamonds=Diamonds($targetArr[i][j]);
						if (IsNotPropOfDiamond(card.id) && closeArr.indexOf(card) == -1)
						{
							closeArr.push(card);
						}
					}
				}
			}
			return closeArr;
		}
		
		/**
		 * 此方法作用在整块内搜索同种颜色的钻石（彩色炸弹
		 * @param $targetArr 指定搜索的目标数组
		 * @param card 当前点击的钻石或道具对象
		 * @return Array
		 * 
		 */
		static public function findAllPurpleCard($targetArr:Array, $diamond:Diamonds):Vector.<Diamonds>
		{
			var diamond:Diamonds;
			var closeArr:Vector.<Diamonds>	= new Vector.<Diamonds>();
			var selectDiamondColorId:int	= 104;
			switch ($diamond.id)
			{
				case 106:
					selectDiamondColorId = 1;
					break;
				case 107:
					selectDiamondColorId = 2;
					break;
				case 104:
					selectDiamondColorId = 3;
					break;
				case 108:
					selectDiamondColorId = 4;
					break;
				case 109:
					selectDiamondColorId = 5;
					break;
			}
			for each (var ary:Array in $targetArr)
			{
				for each (diamond in ary)
				{
					if (diamond.id == selectDiamondColorId || (diamond == $diamond))
					{
						if (closeArr.indexOf(diamond) == -1) closeArr.push(diamond);
					}
				}
			}
			diamond=null;
			return closeArr;
		}
		
		/**
		 * 此方法作用在于十字爆破块搜索
		 * @param $targetArr 指定搜索的目标数组
		 * @param card 当前点击的钻石或道具对象
		 * @return Array
		 * 
		 */
		static public function findCrossCard($targetArr:Array, $diamond:Diamonds):Vector.<Diamonds>
		{
			var closeArr:Vector.<Diamonds>	= new Vector.<Diamonds>();
			var index_i:int		= $diamond.rows;
			var index_j:int		= $diamond.cols;
			$diamond.visible		= true;
			closeArr.push($diamond);
			var ary:Array = $targetArr[index_i];
			for each ($diamond in ary)
			{
				if (IsNotPropOfDiamond($diamond.id) && closeArr.indexOf($diamond) == -1)
				{
					closeArr.push($diamond);
				}
			}
			var i:int=0;
			var rows:int = DispelMainType.ROWS;
			for (i = 0; i < rows; i++)
			{
				$diamond = Diamonds($targetArr[i][index_j]);
				if (IsNotPropOfDiamond($diamond.id) && closeArr.indexOf($diamond) == -1)
				{
					closeArr.push($diamond);
				}
			}
			return closeArr;
		}
		
		/**
		 * 此方法作用在于兴奋状态下连续消除搜索（极速
		 * @param $targetArr 指定搜索的目标数组
		 * @param card 当前点击的钻石或道具对象
		 * @return Array
		 * 
		 */
		static public function findExcitingCard($targetArr:Array, $card:Diamonds):Vector.<Diamonds>
		{
			var $findedDiamonds:Vector.<Diamonds>	= findCard($targetArr, $card, true);
			
			return findExcitingCardHasFindArray($targetArr, $findedDiamonds);
		}
		
		static public function findExcitingCardHasFindArray($targetArr:Array, $findedDiamonds:Vector.<Diamonds>):Vector.<Diamonds>
		{
			var closeArr:Vector.<Diamonds>	= new Vector.<Diamonds>();
			var diamond:Diamonds;
			for each (diamond in $findedDiamonds)
			{
				closeArr.push(diamond);
				diamond.isSeeked = true;
			}
			var colsMax:int = DispelMainType.COLS - 1;
			var rowsMax:int = DispelMainType.ROWS - 1;
			var index_i:int;
			var index_j:int;
			for each (diamond in $findedDiamonds)
			{
				index_i = diamond.rows;
				index_j = diamond.cols;
				if (index_j < colsMax)
				{
					diamond = Diamonds($targetArr[index_i][index_j + 1]) //正右边的卡片
					if (diamond) isToPush(); 
				}
				if (index_j > 0) //查找左边
				{
					diamond = Diamonds($targetArr[index_i][index_j - 1]) //正左边的卡片
					if (diamond) isToPush(); 
				}
				if (index_i > 0)
				{
					diamond = Diamonds($targetArr[index_i - 1][index_j]) //上边的卡片
					if (diamond) isToPush(); 
				}
				if (index_i < rowsMax)
				{
					diamond = Diamonds($targetArr[index_i + 1][index_j]) //下边的卡片
					if (diamond) isToPush(); 
				}
				diamond = null;
			}
			function isToPush():void
			{
				if (!diamond.isSeeked)
				{
					diamond.isSeeked=true;
					if (IsNotPropOfDiamond(diamond.id) && closeArr.indexOf(diamond) == -1)
					{
						closeArr.push(diamond);
					}
				}
			}
			
			setCardIsVisiedAttribute(closeArr);
			
			return closeArr;
		}
		
		/**
		 * 此方法作用在于方阵搜索；(第一个参数为点击的卡片，第二，三个参数为方阵的行数与列数,一般情况下行数等于列数)
		 * @param $targetArr 指定搜索的目标数组
		 * @param card 当前点击的钻石或道具对象
		 * @param rows 方阵的行数
		 * @param cols 方阵的列数
		 * @return Array
		 * 
		 */
		static public function findMatrixCard($targetArr:Array, $card:Diamonds, $rows:int, $cols:int):Vector.<Diamonds>
		{
			var closeArr:Vector.<Diamonds>	= new Vector.<Diamonds>();
			$rows = $rows * 0.5;
			$cols = $cols * 0.5;
			
			var start_row:int	= $card.rows - $rows;
			var end_row:int		= $card.rows + $rows;
			var start_col:int	= $card.cols - $cols;
			var end_col:int		= $card.cols + $cols;
			$rows = DispelMainType.ROWS - 1;
			$cols = DispelMainType.COLS - 1;
			
			start_row			= start_row < 0 ? 0 : start_row;
			start_col			= start_col < 0 ? 0 : start_col;
			end_row				= end_row > $rows ? $rows : end_row;
			end_col				= end_col > $cols ? $cols : end_col;
			closeArr.push($card);
			var m:int;
			var n:int;
			for (m = start_row; m <= end_row; m++)
			{
				for (n = start_col; n <= end_col; n++)
				{
					$card = Diamonds($targetArr[m][n]);
					if (IsNotPropOfDiamond($card.id) && closeArr.indexOf($card) == -1)
					{
						closeArr.push($card);
					}
				}
			}
			return closeArr;
		}
		
		/**
		 * 此方法作用在于相同区域块搜索；
		 * 用两个数组（openArr,closeArr)来实现,openArr用于存储搜索到的上下左右卡片，closeArr用来存储最终的块区域卡片
		 * @param $targetArr 指定搜索的目标数组
		 * @param $card 当前点击的钻石或道具对象
		 * @param $isExciting 是否是兴奋状态下的查找，默认为false
		 * @return Array
		 * 
		 */
		static public function findCard($targetArr:Array, $card:Diamonds, $isExciting:Boolean=false):Vector.<Diamonds>
		{
			var closeArr:Vector.<Diamonds> = new Vector.<Diamonds>();
			var openArr:Vector.<Diamonds> = new Vector.<Diamonds>();
			var targetCard:Diamonds;
			openArr.unshift($card);
			$card.isSeeked = true;
			var index_i:int;
			var index_j:int;
			var colsMax:int = DispelMainType.COLS - 1;
			var rowsMax:int = DispelMainType.ROWS - 1;
			while (openArr.length > 0)
			{
				index_i = $card.rows;
				index_j = $card.cols;
				if (index_j < colsMax) //查找右边
				{
					targetCard = Diamonds($targetArr[index_i][index_j + 1]);
					if (targetCard) checkCard(); 
				}
				if (index_j > 0) //查找左边
				{
					targetCard = Diamonds($targetArr[index_i][index_j - 1]);
					if (targetCard) checkCard(); 
				}
				if (index_i > 0) //查找上边
				{
					targetCard = Diamonds($targetArr[index_i - 1][index_j]);
					if (targetCard) checkCard(); 
				}
				if (index_i < rowsMax) //查找下边
				{
					targetCard = Diamonds($targetArr[index_i + 1][index_j]);
					if (targetCard) checkCard(); 
				}
				$card = Diamonds(openArr.shift());
				closeArr.push($card);
				if (openArr.length == 0) break;
			}
			
			function checkCard():void
			{
				if (!targetCard.isSeeked)
				{
					if (targetCard.id == $card.id && closeArr.indexOf(targetCard) == -1)
					{
						targetCard.isSeeked = true;
						openArr.unshift(targetCard);
					}
				}
			}
			if ($isExciting == false)
			{
				setCardIsVisiedAttribute(closeArr);
			}
			openArr = null;
			targetCard = null;
			
			return closeArr;
		}
		
		private static function setCardIsVisiedAttribute(closeArr:Vector.<Diamonds>):void
		{
			for each (var ij:Diamonds in closeArr)
			{
				ij.isSeeked = false;
			}
		}
		
		private static function IsNotPropOfDiamond($diamondId:int):Boolean
		{
			if ($diamondId > 0 && $diamondId <= DispelMainType.DIAMOND_COLOR_NUM)
			{
				return true;
			}
			return false;
		}

		
		/////////////////////////////////////////private ////////////////////////////////
		
		
	}
	
}