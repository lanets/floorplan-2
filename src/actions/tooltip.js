// @flow

import type { Action } from './types';


export function showTooltip(x: number, y:number, text: string): Action {
  return {
    type: 'SHOW_TOOLTIP',
    x,
    y,
    text,
  };
}