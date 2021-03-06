//= require vue
//= require environments/components/environment_external_url

describe('External URL Component', () => {
  fixture.preload('environments/element.html');
  beforeEach(() => {
    fixture.load('environments/element.html');
  });

  it('should link to the provided externalUrl prop', () => {
    const externalURL = 'https://doggohub.com';
    const component = new window.gl.environmentsList.ExternalUrlComponent({
      el: document.querySelector('.test-dom-element'),
      propsData: {
        externalUrl: externalURL,
      },
    });

    expect(component.$el.getAttribute('href')).toEqual(externalURL);
    expect(component.$el.querySelector('fa-external-link')).toBeDefined();
  });
});
