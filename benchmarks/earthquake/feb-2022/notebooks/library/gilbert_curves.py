#!/usr/bin/env python
# coding: utf-8

# # Space Filling Curves

# In[ ]:


from typing import Callable, Dict, List, Optional, Tuple, Union


def cal_gilbert2d(width: int, height: int) -> List[Tuple[int, int]]:
    coordinates: List[Tuple[int, int]] = []

    def sgn(x: int) -> int:
        return (x > 0) - (x < 0)

    def gilbert2d(x: int, y: int, ax: int, ay: int, bx: int, by: int):
        """
        Generalized Hilbert ('gilbert') space-filling curve for arbitrary-sized
        2D rectangular grids.
        """

        w = abs(ax + ay)
        h = abs(bx + by)

        (dax, day) = (sgn(ax), sgn(ay))  # unit major direction
        (dbx, dby) = (sgn(bx), sgn(by))  # unit orthogonal direction

        if h == 1:
            # trivial row fill
            for i in range(0, w):
                coordinates.append((x, y))
                (x, y) = (x + dax, y + day)
            return

        if w == 1:
            # trivial column fill
            for i in range(0, h):
                coordinates.append((x, y))
                (x, y) = (x + dbx, y + dby)
            return

        (ax2, ay2) = (ax // 2, ay // 2)
        (bx2, by2) = (bx // 2, by // 2)

        w2 = abs(ax2 + ay2)
        h2 = abs(bx2 + by2)

        if 2 * w > 3 * h:
            if (w2 % 2) and (w > 2):
                # prefer even steps
                (ax2, ay2) = (ax2 + dax, ay2 + day)

            # long case: split in two parts only
            gilbert2d(x, y, ax2, ay2, bx, by)
            gilbert2d(x + ax2, y + ay2, ax - ax2, ay - ay2, bx, by)

        else:
            if (h2 % 2) and (h > 2):
                # prefer even steps
                (bx2, by2) = (bx2 + dbx, by2 + dby)

            # standard case: one step up, one long horizontal, one step down
            gilbert2d(x, y, bx2, by2, ax2, ay2)
            gilbert2d(x + bx2, y + by2, ax, ay, bx - bx2, by - by2)
            gilbert2d(
                x + (ax - dax) + (bx2 - dbx),
                y + (ay - day) + (by2 - dby),
                -bx2,
                -by2,
                -(ax - ax2),
                -(ay - ay2),
            )

    if width >= height:
        gilbert2d(0, 0, width, 0, 0, height)
    else:
        gilbert2d(0, 0, 0, height, width, 0)
    return coordinates


def lookup_color(unique_colors, color_value: float) -> int:
    ids = np.where(unique_colors == color_value)
    color_id = ids[0][0]
    return color_id


def plot_gilbert2d_space_filling(
    vertices: List[Tuple[int, int]],
    width: int,
    height: int,
    filling_color: Optional[np.ndarray] = None,
    color_map: str = "rainbow",
    figsize: Tuple[int, int] = (12, 8),
    linewidth: int = 1,
) -> None:

    fig, ax = plt.subplots(figsize=figsize)
    patch_list: List = []

    if filling_color is None:
        cmap = matplotlib.cm.get_cmap(color_map, len(vertices))
        for i in range(len(vertices) - 1):
            path = Path([vertices[i], vertices[i + 1]], [Path.MOVETO, Path.LINETO])
            patch = patches.PathPatch(path, fill=False, edgecolor=cmap(i), lw=linewidth)
            patch_list.append(patch)
        ax.set_xlim(-1, width)
        ax.set_ylim(-1, height)

    else:
        unique_colors = np.unique(filling_color)
        #        np.random.shuffle(unique_colors)
        cmap = matplotlib.cm.get_cmap(color_map, len(unique_colors))

        for i in range(len(vertices) - 1):
            x, y = vertices[i]
            fi, fj = x, height - 1 - y
            color_value = filling_color[fj, fi]
            color_id = lookup_color(unique_colors, color_value)
            path = Path(
                [rescale_xy(x, y), rescale_xy(vertices[i + 1][0], vertices[i + 1][1])],
                [Path.MOVETO, Path.LINETO],
            )
            # path = Path([vertices[i], vertices[i + 1]], [Path.MOVETO, Path.LINETO])
            patch = patches.PathPatch(
                path, fill=False, edgecolor=cmap(color_id), lw=linewidth
            )
            patch_list.append(patch)
        ax.set_xlim(-120 - 0.1, width / 10 - 120)
        ax.set_ylim(32 - 0.1, height / 10 + 32)

    collection = matplotlib.collections.PatchCollection(patch_list, match_original=True)
    # collection.set_array()
    # plt.colorbar(collection)
    ax.add_collection(collection)
    ax.set_aspect("equal")
    plt.show()
    return


def rescale_xy(x: int, y: int) -> Tuple[float, float]:
    return x / 10 - 120, y / 10 + 32


def remapfaults(InputFaultNumbers, Numxlocations, Numylocations, SpaceFillingCurve):
    TotalLocations = Numxlocations * Numylocations
    OutputFaultNumbers = np.full_like(InputFaultNumbers, -1, dtype=np.int)
    MaxOldNumber = np.amax(InputFaultNumbers)
    mapping = np.full(MaxOldNumber + 1, -1, dtype=np.int)
    newlabel = -1
    for sfloc in range(0, TotalLocations):
        [x, y] = SpaceFillingCurve[sfloc]
        pixellocation = y * Numxlocations + x
        pixellocation1 = y * Numxlocations + x
        oldfaultnumber = InputFaultNumbers[pixellocation1]
        if mapping[oldfaultnumber] < 0:
            newlabel += 1
            mapping[oldfaultnumber] = newlabel
        OutputFaultNumbers[pixellocation] = mapping[oldfaultnumber]
    MinNewNumber = np.amin(OutputFaultNumbers)
    if MinNewNumber < 0:
        printexit("Incorrect Fault Mapping")
    print("new Fault Labels generated 0 through " + str(newlabel))
    plot_gilbert2d_space_filling(
        SpaceFillingCurve,
        Numxlocations,
        Numylocations,
        filling_color=np.reshape(OutputFaultNumbers, (40, 60)),
        color_map="gist_ncar",
    )
    return OutputFaultNumbers


def annotate_faults_ndarray(
    pix_faults: np.ndarray, figsize=(10, 8), color_map="rainbow"
):
    matplotlib.rcParams.update(matplotlib.rcParamsDefault)
    plt.rcParams.update({"font.size": 12})
    unique_colors = np.unique(pix_faults)
    np.random.shuffle(unique_colors)
    cmap = matplotlib.cm.get_cmap(color_map, len(unique_colors))

    fig, ax = plt.subplots(figsize=figsize)
    height, width = pix_faults.shape
    for j in range(height):
        for i in range(width):
            x, y = i / 10 - 120, (height - j - 1) / 10 + 32
            ax.annotate(
                str(pix_faults[j, i]), (x + 0.05, y + 0.05), ha="center", va="center"
            )
            color_id = lookup_color(unique_colors, pix_faults[j, i])
            ax.add_patch(
                patches.Rectangle((x, y), 0.1, 0.1, color=cmap(color_id), alpha=0.5)
            )
    ax.set_xlim(-120, width / 10 - 120)
    ax.set_ylim(32, height / 10 + 32)
    plt.show()

