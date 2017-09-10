# TorusBounces

This is a tool for simulating the trajectory of a particle inside of a deformed torus. The Processing applet allows for interactive exploration of the results for different initial conditions.

### Usage

![some scatter plots layered over each other](images/applet_screenshot.jpg)

The two large windows are plots of the points where the particle hits the torus given some initial condition. The left plot shows the positions in toroidal coordinates, and the right shows azumuthal angular momentum versus azimuthal angle of the hit point. Clicking in the left window will generate a new scatter plot with the initial conditions determined by your mouse position (the corresponding position inside the torus appears in the 3D preview).

The first two sliders in the settings window allow you to change the initial launch direction (with respect to the surface normal). The last two pertain to the detailed analysis feature, which renders the trajectory in the 3D preview, starting and ending at the specified bounces if the "render" checkbox is selected.

![rendering feature](images/applet_screenshot2.jpg)

When this mode is active, only the active trajectory will be shown in the scatter plots, and you can isolate any interesting behavior you see by adjusting the start and end sliders.

### Dependencies:
- The Julia code depends on the Plots.jl package.
- The Processing applet depends on the G4P library for user interface widgets.
