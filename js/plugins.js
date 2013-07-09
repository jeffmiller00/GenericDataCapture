window.log = function(){
  log.history = log.history || [];  
  log.history.push(arguments);
  arguments.callee = arguments.callee.caller;  
  if(this.console) console.log( Array.prototype.slice.call(arguments) );
};
(function(b){function c(){}for(var d="assert,count,debug,dir,dirxml,error,exception,group,groupCollapsed,groupEnd,info,log,markTimeline,profile,profileEnd,time,timeEnd,trace,warn".split(","),a;a=d.pop();)b[a]=b[a]||c})(window.console=window.console||{});



/* 
 * Menu plugin
 * Source: http://tympanus.net/codrops/2010/11/25/overlay-effect-menu/
 *  
 * */
$(function() {
	var $oe_menu		= $('#oe_menu');
	var $oe_menu_items	= $oe_menu.children('li');
	var $oe_overlay		= $('#oe_overlay');

    $oe_menu_items.bind('mouseenter',function(){
		var $this = $(this);
		$this.addClass('slided selected');
		$this.children('div').css('z-index','9999').stop(true,true).slideDown(200,function(){
			$oe_menu_items.not('.slided').children('div').hide();
			$this.removeClass('slided');
		});
	}).bind('mouseleave',function(){
		var $this = $(this);
		$this.removeClass('selected').children('div').css('z-index','1');
	});

	$oe_menu.bind('mouseenter',function(){
		var $this = $(this);
		$oe_overlay.stop(true,true).fadeTo(200, 0.6);
		$this.addClass('hovered');
	}).bind('mouseleave',function(){
		var $this = $(this);
		$this.removeClass('hovered');
		$oe_overlay.stop(true,true).fadeTo(200, 0);
		$oe_menu_items.children('div').hide();
	})
});