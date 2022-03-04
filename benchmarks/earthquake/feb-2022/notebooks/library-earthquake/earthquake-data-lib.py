#!/usr/bin/env python
# coding: utf-8

# In[ ]:


def makeadateplot(
    plotfigure,
    plotpointer,
    Dateaxis=None,
    datemin=None,
    datemax=None,
    Yearly=True,
    majoraxis=5,
):
    if not Yearly:
        sys.exit("Only yearly supported")
    plt.rcParams.update({"font.size": 9})
    years5 = mdates.YearLocator(majoraxis)  # every 5 years
    years_fmt = mdates.DateFormatter("%Y")
    plotpointer.xaxis.set_major_locator(years5)
    plotpointer.xaxis.set_major_formatter(years_fmt)
    if datemin is None:
        datemin = np.datetime64(Dateaxis[0], "Y")
    if datemax is None:
        datemax = np.datetime64(Dateaxis[-1], "Y") + np.timedelta64(1, "Y")
    plotpointer.set_xlim(datemin, datemax)
    plotfigure.autofmt_xdate()
    return datemin, datemax


def makeasmalldateplot(figure, ax, Dateaxis):
    plt.rcParams.update({"font.size": 9})
    months = mdates.MonthLocator(interval=2)  # every month
    datemin = np.datetime64(Dateaxis[0], "M")
    datemax = np.datetime64(Dateaxis[-1], "M") + np.timedelta64(1, "M")
    ax.set_xlim(datemin, datemax)

    months_fmt = mdates.DateFormatter("%y-%b")
    locator = mdates.AutoDateLocator()
    locator.intervald["MONTHLY"] = [2]
    formatter = mdates.ConciseDateFormatter(locator)
    #  ax.xaxis.set_major_locator(locator)
    #  ax.xaxis.set_major_formatter(formatter)
    ax.xaxis.set_major_locator(months)
    ax.xaxis.set_major_formatter(months_fmt)

    figure.autofmt_xdate()
    return datemin, datemax


def Addfixedearthquakes(
    plotpointer,
    graphmin,
    graphmax,
    ylogscale=False,
    quakecolor=None,
    Dateplot=True,
    vetoquake=None,
):
    if vetoquake is None:  # Vetoquake = True means do not plot this quake
        vetoquake = np.full(numberspecialeqs, False, dtype=np.bool)
    if quakecolor is None:  # Color of plot
        quakecolor = "black"
    Place = np.arange(numberspecialeqs, dtype=np.int)
    Place[8] = 11
    Place[10] = 3
    Place[12] = 16
    Place[7] = 4
    Place[2] = 5
    Place[4] = 14
    Place[11] = 18

    ymin, ymax = plotpointer.get_ylim()  # Or work with transform=ax.transAxes

    for iquake in range(0, numberspecialeqs):
        if vetoquake[iquake]:
            continue

        # This is the x position for the vertical line
        if Dateplot:
            x_line_annotation = Specialdate[iquake]  # numpy date format
        else:
            x_line_annotation = Numericaldate[
                iquake
            ]  # Float where each interval 1 and start is 0
        if (x_line_annotation < graphmin) or (x_line_annotation > graphmax):
            continue

        # This is the x position for the label
        if Dateplot:
            x_text_annotation = x_line_annotation + np.timedelta64(5 * Dailyunit, "D")
        else:
            x_text_annotation = x_line_annotation + 5.0
        # Draw a line at the position
        plotpointer.axvline(
            x=x_line_annotation,
            linestyle="dashed",
            alpha=1.0,
            linewidth=0.5,
            color=quakecolor,
        )
        # Draw a text
        if Specialuse[iquake]:
            ascii = str(round(Specialmags[iquake], 1)) + "\n" + Specialeqname[iquake]
            if ylogscale:
                yminl = max(0.01 * ymax, ymin)
                yminl = math.log(yminl, 10)
                ymaxl = math.log(ymax, 10)
                logyplot = yminl + (
                    0.1 + 0.8 * (float(Place[iquake]) / float(numberspecialeqs - 1))
                ) * (ymaxl - yminl)
                yplot = pow(10, logyplot)
            else:
                yplot = ymax - (
                    0.1 + 0.8 * (float(Place[iquake]) / float(numberspecialeqs - 1))
                ) * (ymax - ymin)
            if Dateplot:
                if x_text_annotation > graphmax - np.timedelta64(2000, "D"):
                    x_text_annotation = graphmax - np.timedelta64(2000, "D")
            else:
                if x_text_annotation > graphmax - 100:
                    x_text_annotation = graphmax - 100
            #      print(str(yplot) + " " + str(ymin) + " " + str(ymax) + " " + str(x_text_annotation) + " " + str(x_line_annotation)) + " " + ascii
            plotpointer.text(
                x=x_text_annotation,
                y=yplot,
                s=wraptotext(ascii, size=10),
                alpha=1.0,
                color="black",
                fontsize=6,
            )


def quakesearch(iquake, iloc):
    # see if top earthquake iquake llies near location iloc
    # result = 0 NO; =1 YES Primary: locations match exactly; = -1 Secondary: locations near
    # iloc is location before mapping
    xloc = iloc % 60
    yloc = (iloc - xloc) / 60
    if (xloc == Specialxpos[iquake]) and (yloc == Specialypos[iquake]):
        return 1
    if (abs(xloc - Specialxpos[iquake]) <= 1) and (
        abs(yloc - Specialypos[iquake]) <= 1
    ):
        return -1
    return 0


# Read Earthquake Data
def log_sum_exp10(ns, sumaxis=0):
    max_v = np.max(ns, axis=None)
    ds = ns - max_v
    sum_of_exp = np.power(10, ds).sum(axis=sumaxis)
    return max_v + np.log10(sum_of_exp)


def log_energyweightedsum(nvalue, ns, sumaxis=0):
    max_v = np.max(ns, axis=None)
    ds = ns - max_v
    ds = np.power(10, 1.5 * ds)
    dvalue = (np.multiply(nvalue, ds)).sum(axis=sumaxis)
    ds = ds.sum(axis=0)
    return np.divide(dvalue, ds)


# Set summed magnitude as log summed energy = 10^(1.5 magnitude)
def log_energy(mag, sumaxis=0):
    return log_sum_exp10(1.5 * mag, sumaxis=sumaxis) / 1.5


def AggregateEarthquakes(
    itime, DaysDelay, DaysinInterval, Nloc, Eqdata, Approach, weighting=None
):
    if (itime + DaysinInterval + DaysDelay) > NumberofTimeunits:
        return np.full([Nloc], NaN, dtype=np.float32)
    if Approach == 0:  # Magnitudes
        if MagnitudeMethod == 0:
            TotalMagnitude = log_energy(
                Eqdata[itime + DaysDelay : itime + DaysinInterval + DaysDelay]
            )
        else:
            TotalMagnitude = Eqdata[
                itime + DaysDelay : itime + DaysinInterval + DaysDelay, :
            ].sum(axis=0)
        return TotalMagnitude
    if Approach == 1:  # Depth -- energy weighted
        WeightedResult = log_energyweightedsum(
            Eqdata[itime + DaysDelay : itime + DaysinInterval + DaysDelay],
            weighting[itime + DaysDelay : itime + DaysinInterval + DaysDelay],
        )
        return WeightedResult
    if Approach == 2:  # Multiplicity -- summed
        SimpleSum = Eqdata[
            itime + DaysDelay : itime + DaysinInterval + DaysDelay, :
        ].sum(axis=0)
        return SimpleSum


def TransformMagnitude(mag):
    if MagnitudeMethod == 0:
        return mag
    if MagnitudeMethod == 1:
        return np.power(10, 0.375 * (mag - 3.29))
    return np.power(10, 0.75 * (mag - 3.29))


# Change Daily Unit
# Accumulate data in Dailyunit chunks.
# This changes data so it looks like daily data bu really collections of chunked data.
# For earthquakes, the aggregations uses energy averaging for depth and magnitude. It just adds for multiplicity
def GatherUpData(OldInputTimeSeries):
    Skipped = NumberofTimeunits % Dailyunit
    NewInitialDate = InitialDate + timedelta(days=Skipped)
    NewNum_Time = int(Num_Time / Dailyunit)
    NewFinalDate = NewInitialDate + Dailyunit * timedelta(days=NewNum_Time - 1)
    print(
        " Daily Unit "
        + str(Dailyunit)
        + " number of "
        + TimeIntervalUnitName
        + " Units "
        + str(NewNum_Time)
        + " "
        + NewInitialDate.strftime("%d/%m/%Y")
        + " To "
        + NewFinalDate.strftime("%d/%m/%Y")
    )
    NewInputTimeSeries = np.empty(
        [NewNum_Time, Nloc, NpropperTimeDynamicInput], dtype=np.float32
    )
    for itime in range(0, NewNum_Time):
        NewInputTimeSeries[itime, :, 0] = AggregateEarthquakes(
            Skipped + itime * Dailyunit,
            0,
            Dailyunit,
            Nloc,
            BasicInputTimeSeries[:, :, 0],
            0,
        )
        NewInputTimeSeries[itime, :, 1] = AggregateEarthquakes(
            Skipped + itime * Dailyunit,
            0,
            Dailyunit,
            Nloc,
            BasicInputTimeSeries[:, :, 1],
            1,
            weighting=BasicInputTimeSeries[:, :, 0],
        )
        NewInputTimeSeries[itime, :, 2] = AggregateEarthquakes(
            Skipped + itime * Dailyunit,
            0,
            Dailyunit,
            Nloc,
            BasicInputTimeSeries[:, :, 2],
            2,
        )
        NewInputTimeSeries[itime, :, 3] = AggregateEarthquakes(
            Skipped + itime * Dailyunit,
            0,
            Dailyunit,
            Nloc,
            BasicInputTimeSeries[:, :, 3],
            2,
        )
    return NewInputTimeSeries, NewNum_Time, NewNum_Time, NewInitialDate, NewFinalDate

