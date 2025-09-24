# QX Toolbox (New 2025) for 3ds Max 🎨

A comprehensive collection of scripts designed to streamline common workflows in 3ds Max, developed between 2023 and 2025. This toolbox automates tedious tasks, from scene cleanup and asset management to V-Ray render optimization, allowing artists to focus on creativity and production.

## 🚀 Key Features

### 🔧 Scene & Asset Management

* **Map Browser**: An advanced tool for checking and managing scene maps. Quickly identify **missing maps**, view map properties, and load them into the Material Editor. It features a robust search function and color-coded statuses to help you pinpoint issues instantly. 
* **V-Ray Material Tools**: A powerful utility for standardizing V-Ray material settings across your scene. Select objects and adjust their diffuse, reflection, refraction, and bump properties in a single, intuitive interface. This is perfect for ensuring consistent quality or quickly changing render settings for test scenes.
* **Non-V-Ray Material Finder**: This one-click tool finds and selects all objects in your scene that are assigned non-V-Ray materials. This is crucial for optimizing rendering performance and troubleshooting unexpected shading.
* **Object to Dummy**: Replaces selected objects with point dummies, automatically placing the original objects into a hidden layer. This is an essential function for managing heavy scenes, improving viewport performance, and preparing assets for external workflows.
* **Layer & Channel Fix**:
    * **Layer Fix**: Corrects a common bug in 3ds Max 2017/2018 where objects can lose their layers. The tool re-assigns selected objects to a new layer, ensuring proper scene organization.
    * **Channel Fix**: Streamlines your render pass workflow by automatically removing existing **MultiMatteElements** and creating new ones based on your specified G-Buffer channel and material ID counts.
* **FBX/RVT Import Cleaner**: A dedicated tool for optimizing imported FBX and RVT files. It automatically deletes all cameras, lights, and helpers, and resets XForm on all geometry. It also assigns a random wire color to each object and converts all objects to editable mesh for a clean, workable scene. A more general-purpose import cleaner is also included.

### 💡 Rendering & Optimization

* **Material ID and Camera Info**: This dual-function tool provides critical information about your scene's setup.
    * **Material ID Check**: Scans your scene for all materials with an effects channel (Material ID) and flags any duplicated IDs, which can cause issues in post-production. The results can be exported to a `.txt` file for easy reference.
    * **Camera Info**: Provides a detailed report on all physical cameras in your scene, including lens focal length, exposure settings (f-number, shutter speed, ISO), and transform lock status. This is invaluable for documenting and replicating camera setups.
* **Render Setting Presets**: Quickly switch between **Low**, **Medium**, and **High** V-Ray render quality presets with a single click. These presets are designed to provide a fast workflow for test renders and final production.
* **Default Render Elements**: Automatically adds a comprehensive list of essential V-Ray render elements to your scene, including Diffuse, GI, Reflection, Refraction, Specular, ZDepth, and more. It also includes an automatically configured **VRayDirt** texture for an Ambient Occlusion pass.
* **Clear Render Output File**: A simple but effective tool to clear any set render output file path, preventing accidental overwrites.
* **Asset Tracking**: Provides quick access to the native 3ds Max Asset Tracking System, helping you to identify and manage file paths and missing assets.
* **V-Ray Proxy Box Mode**: Toggles the display mode of all selected V-Ray Proxy objects between **Full Mesh** and **Bounding Box**, significantly improving viewport performance.
* **Reference Plane Creator**: A quick utility to create a reference plane with a specified size. It automatically assigns a V-Ray material and a bitmap texture to the plane and configures the UVW map. It can also bring the material into the active Material Editor slot.

### 🔎 Utilities & Maintenance

* **Modifier Check**: Scans your scene for objects with disabled modifiers and provides a report. It also automatically selects these objects so you can quickly address them.
* **Project Directory**: Opens the current 3ds Max project directory in a new explorer window, saving you from navigating through folders.
* **V-Ray Documentation**: A quick button that opens the official V-Ray documentation website, providing fast access to help and information.

## 🖼️ Screenshots

A visual guide to the toolbox's user interface and its various functions.

* **Main Floater**: A screenshot of the consolidated main toolbox floater, showing all categorized functions.
* **Map Browser**: A screenshot of the Map Browser UI, demonstrating how to check for missing maps and their properties.
* **V-Ray Material Setting**: A screenshot of the V-Ray Material Setting dialog, showcasing the various parameters that can be adjusted.
* **Material ID Check**: A screenshot of the message box displaying the Material ID report, including duplicated IDs.

## 🛠️ Installation

1.  Download the repository as a ZIP file.
2.  Unzip the contents to a folder on your computer.
3.  Open 3ds Max.
4.  Drag and drop the `qx_toolbox.mcr` file into the 3ds Max viewport.
5.  A dialog will pop up, confirming the installation.
6.  To launch the script, go to **Customize** > **Customize User Interface**.
7.  In the "Toolbars" tab, under the "Category" dropdown, find **"QX_Toolbox"**.
8.  Drag the **"QX_Toolbox"** action onto a toolbar in your UI. You can also assign a keyboard shortcut or a quad menu item if you prefer.

## 💡 Notes

* **V-Ray Compatibility**: The rendering tools are designed for V-Ray. While the scene and asset management tools are universal, the V-Ray-specific functions may not work with other renderers.
* **Undos**: All operations are undoable via the standard **Ctrl+Z** hotkey, so feel free to experiment without worry.
* **File Paths**: Some internal paths are hardcoded for `ms*` files. Ensure all files (`.mse`) from the toolbox are in the same folder as the main `.mcr` file.

Happy rendering!
