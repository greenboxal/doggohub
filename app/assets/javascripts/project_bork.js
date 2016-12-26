/* eslint-disable func-names, space-before-function-paren, wrap-iife, prefer-arrow-callback, padded-blocks, max-len */
(function() {
  this.ProjectBork = (function() {
    function ProjectBork() {
      $('.bork-thumbnail a').on('click', function() {
        $('.bork-namespaces').hide();
        return $('.save-project-loader').show();
      });
    }

    return ProjectBork;

  })();

}).call(this);
