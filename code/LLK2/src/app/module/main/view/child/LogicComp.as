package app.module.main.view.child
{
	import com.greensock.TimelineMax;
	import com.greensock.TweenAlign;
	import com.greensock.TweenMax;
	import com.greensock.easing.Back;
	import com.greensock.events.TweenEvent;
	
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	import app.AppStage;
	import app.EffectControl;
	import app.manager.SoundManager;
	import app.core.components.Button;
	import app.data.LevelVo;
	import app.module.main.events.MainEvent;
	import app.module.main.view.ElementConfig;
	import app.module.main.view.element.Element;
	import app.module.main.view.element.IElement;
	import app.utils.ArrayUtil;

	[Event( name = "back_menu", type = "app.module.main.events.MainEvent" )]

	[Event( name = "dispel_success", type = "app.module.main.events.MainEvent" )]

	[Event( name = "add_score", type = "app.module.main.events.MainEvent" )]

	[Event( name = "add_time", type = "app.module.main.events.MainEvent" )]

	/**
	 * ……
	 * @author 	yangsj
	 * 			2013-6-21
	 */
	public class LogicComp extends Sprite
	{

		// item 列表显示容器
		private var _listContainer:Sprite;
		// 路径线显示容器
		private var _drawPathLine:DrawPathLine;
		private var _markList:Vector.<int>;
		private var _itemMap:Vector.<Vector.<IElement>>;
		private var _items:Vector.<IElement>;
		private var _markAry:Vector.<int>;
		private var _seekGroups:Vector.<Vector.<IElement>>;
		private var _startItem:IElement;
		private var _endItem:IElement;
		private var _dispelNumber:int = 0;
		private var _levelVo:LevelVo;
		private var _lastClickTime:Number = 0;
		private var _combNumber:int = 0;
		private var _isOver:Boolean = false;
		private var _btnRefresh:Button;
		private var _btnBack:Button;
		private var _findPath:FindPath;
		private var _moveElementPos:MoveElementPos;
		private var _directionIcon:DrawDirectionIcon;

		private var _moveIntervalTime:Number = 0;

		public function LogicComp()
		{
			mouseEnabled = false;
			intiVars();
		}

		private function intiVars():void
		{
			var vec1:Vector.<IElement>;
			_itemMap = new Vector.<Vector.<IElement>>( ElementConfig.ROWS );
			_items = new Vector.<IElement>()
			for ( var i:uint = 0; i < ElementConfig.ROWS; i++ )
			{
				vec1 = new Vector.<IElement>( ElementConfig.COLS );
				for ( var j:uint = 0; j < ElementConfig.COLS; j++ )
				{
					vec1[ j ] = new Element();
					_items.push( vec1[ j ]);
				}
				_itemMap[ i ] = vec1;
			}
			//
			var leng:uint = 40;
			_markList = new Vector.<int>( leng );
			for ( i = 0; i != leng; i++ )
			{
				_markList[ i ] = ( i + 1 );
			}

			_drawPathLine = new DrawPathLine();
			_listContainer = new Sprite();
			_listContainer.y = 130 * AppStage.scaleY;
			_listContainer.x = ( AppStage.stageWidth - (( _itemMap[ 0 ][ 0 ].itemWidth + 5 ) * ElementConfig.COLS )) >> 1;

			_btnRefresh = new Button( " 刷 新 ", btnRefreshHandler );
			_btnRefresh.x = ( AppStage.stageWidth >> 1 ) - ( _btnRefresh.width >> 1 ) - 10;
			_btnRefresh.y = AppStage.stageHeight - _btnRefresh.height - 10;

			_btnBack = new Button( " 返 回 ", btnBackHandler );
			_btnBack.x = ( AppStage.stageWidth >> 1 ) + ( _btnBack.width >> 1 ) + 10;
			_btnBack.y = AppStage.stageHeight - _btnBack.height - 10;

			_listContainer.mouseEnabled = false;
			_listContainer.addEventListener( MouseEvent.CLICK, clickHandler );

			_findPath = new FindPath();
			_findPath.initMap( _itemMap );

			_moveElementPos = new MoveElementPos();
			_moveElementPos.initMap( _itemMap );
			
			_directionIcon = new DrawDirectionIcon();
			_directionIcon.x = 590;
			_directionIcon.y = 100;
			AppStage.adjustXY( _directionIcon );

			addChild( _listContainer );
			addChild( _drawPathLine );
			addChild( _btnRefresh );
			addChild( _btnBack );
			addChild( _directionIcon );
		}

		private function btnBackHandler():void
		{
			dispatchEvent( new MainEvent( MainEvent.BACK_MENU ));
		}

		private function initMarkData( limit:uint ):void
		{
			limit = Math.min( limit, ElementConfig.LENGTH * 0.5 );
			ArrayUtil.randomSort( _markList );
			_markAry ||= new Vector.<int>( ElementConfig.LENGTH );
			for ( var i:uint = 0; i < ElementConfig.LENGTH; i += 2 )
			{
				_markAry[ i ] = _markAry[ i + 1 ] = _markList[ uint( Math.random() * limit )];
			}
		}

		private function btnRefreshHandler():void
		{
			refresh();
		}

		public function initialize():void
		{
		}

		public function startAndReset( levelVo:LevelVo ):void
		{
			_isOver = false;
			_btnBack.mouseEnabled = false;
			_btnRefresh.mouseEnabled = false;
			_listContainer.removeChildren();
			_dispelNumber = 0;
			_lastClickTime = 0;
			_combNumber = 0;
			_levelVo = levelVo;

			initMarkData( levelVo.picNum );
			ArrayUtil.randomSort( _markAry );
			
			_directionIcon.setDirection( direction );

			var item:IElement;
			var groupAry:Array;
			var tweenGroup:TimelineMax;
			for ( var i:uint = 0; i < ElementConfig.ROWS; i++ )
			{
				groupAry = [];
				for ( var j:uint = 0; j < ElementConfig.COLS; j++ )
				{
					item = _itemMap[ i ][ j ];
					item.parentTarget = _listContainer;
					item.mark = _markAry[ i * ElementConfig.COLS + j ];
					item.cols = j;
					item.rows = i;
					item.initialize();

					groupAry.push( TweenMax.from( item, 0.5, { x: item.x, y: item.y - AppStage.stageHeight, ease: Back.easeOut }));
				}
				tweenGroup = new TimelineMax();
				tweenGroup.addEventListener( TweenEvent.COMPLETE, complete );
				tweenGroup.appendMultiple( groupAry, 1, TweenAlign.START, 0.1 );
				tweenGroup.play();
			}

			function complete( event:TweenEvent ):void
			{
				var target:TimelineMax = event.target as TimelineMax;

				if ( target )
					target.removeEventListener( TweenEvent.COMPLETE, complete );

				if ( _btnRefresh )
					_btnRefresh.mouseEnabled = true;

				if ( _btnBack )
					_btnBack.mouseEnabled = true;
			}
		}

		private function refresh():void
		{
			var row:uint, col:uint;
			var item:IElement;
			ArrayUtil.randomSort( _items );
			for ( var index:int = 0; index < ElementConfig.LENGTH; index++)
			{
				row = index / ElementConfig.COLS;
				col = index % ElementConfig.COLS;
				item = _items[ index ];
				item.rows = row;
				item.cols = col;
				item.refresh();
				_itemMap[ row ][ col ] = item;
			}
			_moveIntervalTime = 0;
			moveElements();
			if ( _startItem )
				_startItem.selected = false;
			_startItem = null;
		}

		protected function clickHandler( event:MouseEvent ):void
		{
			var target:IElement = event.target as IElement;
			if ( target )
			{
				event.stopPropagation();
				if ( _startItem == null )
				{
					_startItem = target;
					_startItem.selected = true;

					SoundManager.playClickItem();
				}
				else
				{
					_endItem = target;
					if ( _endItem == _startItem )
					{
						_startItem.selected = false;
						_startItem = null;

						SoundManager.playClickItem();
					}
					else if ( _startItem.mark != target.mark )
					{
						_startItem.selected = false;
						_endItem.selected = false;
						_startItem.clickError();
						_endItem.clickError();
						_startItem = null;
						_endItem = null;

						SoundManager.playClickError();
					}
					else
					{
						_endItem.selected = true;

						seek();
					}
				}
			}
		}

		///////////// seek

		private function seek():void
		{
			var tempVec1:Vector.<IElement> = _findPath.seek( _startItem, _endItem );
			// get short path
			if ( tempVec1 && tempVec1.length > 0 )
			{
				_dispelNumber++;
				setDrawLine( tempVec1 );
				checkGameProgress();
				checkAddScore();
				SoundManager.playLinkItem();

				moveElements();
			}
			else
			{
				_startItem.selected = false;
				_endItem.selected = false;
				_startItem.clickError();
				_endItem.clickError();
				SoundManager.playClickError();
			}
			_startItem = null;
			_endItem = null;
		}

		private function setDrawLine( tempVec1:Vector.<IElement> ):void
		{
			var tempVec2:Vector.<Point> = new Vector.<Point>();
			_moveIntervalTime = 0.05 * ( tempVec1.length );

			for each ( var item:IElement in tempVec1 )
				tempVec2.push( item.globalPoint );

			_drawPathLine.setPoints( tempVec2 );
			_startItem.removeFromParent( _moveIntervalTime );
			_endItem.removeFromParent( _moveIntervalTime );
		}

		private function checkGameProgress():void
		{
			_isOver = _dispelNumber >= ElementConfig.HALF;
			if ( _isOver )
				dispatchEvent( new MainEvent( MainEvent.DISPEL_SUCCESS ));
			else
				dispatchEvent( new MainEvent( MainEvent.ADD_TIME, 1 ));
		}

		private function checkAddScore():void
		{
			// score
			var score:int = _levelVo.score;

			if ( getTimer() - _lastClickTime <= ElementConfig.COMB_TIME_UNIT )
				_combNumber++;
			else
				_combNumber = 0;

			score += _combNumber * ElementConfig.COMB_REWAR_SCORE_UNIT;
			EffectControl.instance.playCombWords( _combNumber );
			trace( "连击：" + _combNumber, "》》》》》增加分数：" + score );

			if ( _combNumber > 0 && _combNumber % 3 == 0 )
				TweenMax.delayedCall( 0.5, EffectControl.instance.playGoodWords );

			_lastClickTime = getTimer();
			dispatchEvent( new MainEvent( MainEvent.ADD_SCORE, score ));
		}

		private function moveElements():void
		{
			_moveElementPos.moveElements( direction, _moveIntervalTime );
		}

		///***************

		public function get direction():uint
		{
			return _levelVo.direction;
		}


	}
}