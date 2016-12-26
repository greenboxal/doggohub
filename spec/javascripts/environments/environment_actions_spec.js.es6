//= require vue
//= require environments/components/environment_actions

describe('Actions Component', () => {
  fixture.preload('environments/element.html');

  beforeEach(() => {
    fixture.load('environments/element.html');
  });

  it('should render a dropdown with the provided actions', () => {
    const actionsMock = [
      {
        name: 'bar',
        play_path: 'https://doggohub.com/play',
      },
      {
        name: 'foo',
        play_path: '#',
      },
    ];

    const component = new window.gl.environmentsList.ActionsComponent({
      el: document.querySelector('.test-dom-element'),
      propsData: {
        actions: actionsMock,
        playIconSvg: '<svg></svg>',
      },
    });

    expect(
      component.$el.querySelectorAll('.dropdown-menu li').length,
    ).toEqual(actionsMock.length);
    expect(
      component.$el.querySelector('.dropdown-menu li a').getAttribute('href'),
    ).toEqual(actionsMock[0].play_path);
  });

  it('should render a dropdown with the provided svg', () => {
    const actionsMock = [
      {
        name: 'bar',
        play_path: 'https://doggohub.com/play',
      },
      {
        name: 'foo',
        play_path: '#',
      },
    ];

    const component = new window.gl.environmentsList.ActionsComponent({
      el: document.querySelector('.test-dom-element'),
      propsData: {
        actions: actionsMock,
        playIconSvg: '<svg></svg>',
      },
    });

    expect(
      component.$el.querySelector('.js-dropdown-play-icon-container').children,
    ).toContain('svg');

    expect(
      component.$el.querySelector('.js-action-play-icon-container').children,
    ).toContain('svg');
  });
});
