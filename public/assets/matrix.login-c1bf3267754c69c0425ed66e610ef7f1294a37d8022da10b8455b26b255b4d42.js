$(document).ready(function(){$("#loginform"),$("#recoverform");$("#to-recover").click(function(){$("#loginform").slideUp(),$("#recoverform").fadeIn()}),$("#to-login").click(function(){$("#recoverform").hide(),$("#loginform").fadeIn()}),$("#to-login").click(function(){}),1==$.browser.msie&&$.browser.version.slice(0,3)<10&&$("input[placeholder]").each(function(){var o=$(this);$(o).val(o.attr("placeholder")),$(o).focus(function(){o.val()==o.attr("placeholder")&&o.val("")}),$(o).blur(function(){""!=o.val()&&o.val()!=o.attr("placeholder")||o.val(o.attr("placeholder"))})})});