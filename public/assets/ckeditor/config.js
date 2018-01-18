CKEDITOR.editorConfig = function (config) {
  // ... other configuration ...
  config.toolbar_mini = [
    ["Bold",  "Italic",  "Underline",  "Strike",  "-"],
    ['BulletedList','NumberedList' ],['Outdent','Indent'],
   ];
  config.toolbar = "mini";
  config.toolbarLocation = 'bottom';
  config.height = 280;       
  config.width = 620;     
  config.removePlugins = 'elementspath';config.removePlugins = 'elementspath';
  // ... rest of the original config.js  ...
}
;
