import reducer, { initial } from '../../src/reducers/tooltip';
import { showTooltip, hideTooltip } from '../../src/actions/tooltip';


describe('reducer handles SHOW_TOOLTIP action', () => {
  it('sets the display boolean to true', () => {
    const action = showTooltip(50, 100, 'some text goes here');
    const before = initial;
    const after = reducer(before, action);

    expect(after.display).toEqual(true);
  });

  it('sets the x and y values to the action values', () => {
    const action = showTooltip(50, 100, 'some text goes here');
    const before = initial;
    const after = reducer(before, action);

    expect(after.x).toEqual(50);
    expect(after.y).toEqual(100);
  });

  it('sets the text values to the action value', () => {
    const action = showTooltip(50, 100, 'some text goes here');
    const before = initial;
    const after = reducer(before, action);

    expect(after.text).toEqual('some text goes here');
  });
});

describe('reducer handles HIDE_TOOLTIP action', () => {
  it('sets the display boolean to false', () => {
    const action = hideTooltip();
    const before = { ...initial, display: true };
    const after = reducer(before, action);

    expect(after.display).toEqual(false);
  });
});