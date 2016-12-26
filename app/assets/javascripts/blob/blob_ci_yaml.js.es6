/* eslint-disable padded-blocks, no-param-reassign, comma-dangle */
/* global Api */

/*= require blob/template_selector */
((global) => {

  class BlobCiYamlSelector extends gl.TemplateSelector {
    requestFile(query) {
      return Api.doggohubCiYml(query.name, this.requestFileSuccess.bind(this));
    }

    requestFileSuccess(file) {
      return super.requestFileSuccess(file);
    }
  }

  global.BlobCiYamlSelector = BlobCiYamlSelector;

  class BlobCiYamlSelectors {
    constructor({ editor, $dropdowns } = {}) {
      this.editor = editor;
      this.$dropdowns = $dropdowns || $('.js-doggohub-ci-yml-selector');
      this.initSelectors();
    }

    initSelectors() {
      const editor = this.editor;
      this.$dropdowns.each((i, dropdown) => {
        const $dropdown = $(dropdown);
        return new BlobCiYamlSelector({
          editor,
          pattern: /(.doggohub-ci.yml)/,
          data: $dropdown.data('data'),
          wrapper: $dropdown.closest('.js-doggohub-ci-yml-selector-wrap'),
          dropdown: $dropdown
        });
      });
    }
  }

  global.BlobCiYamlSelectors = BlobCiYamlSelectors;

})(window.gl || (window.gl = {}));
