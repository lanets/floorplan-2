/* @flow */


/*
 * Description of the configuration object used to configure the
 * Floorplan.
 */
export type FloorplanConfig = {

  // The id of the div on the HTML page in which the floorplan is going to
  // be displayed.
  div: string,

  // Fired when the user selects an object.
  onObjectSelected: (obj: Object) => void;
};

/**
 *  Structure shown to the client to describe a seat object.
 */
export type SeatData = {
  label: string,
};
