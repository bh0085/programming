import matplotlib.pyplot as plt
import avida_utils as au
import os
import utils.colors as mycolors 
import utils.sigsmooth as ss
import utils.plots as up

import avida_presets as presets

from numpy import *
import numpy as np

resource_grid_figure = 5
fold_grid = True
fold_ts = True

from matplotlib.patches import Circle

print "Setting avida to terminate after lineage domination"

def make_plot(params):
    ptype = params.get('type','ts')
    f = params.get('figure',0)
    
    try:
    
        fig = plt.figure(f)
        
        if ptype == 'ts':
            plot_ts(fig,params)
        else:
        
            plot_grid(fig,params)
                    
    except IndexError,e:
        print e
def plotLinCounts(grid):
    
    n0 = len(nonzero(equal(grid,0))[0])
    n1 = len(nonzero(equal(grid,1))[0])
    
    print shape(nonzero(equal(grid,1)))
    
    print n0
    print n1
    if n0 == 0 or n1 == 0:
        print 'TERMINATING BECAUSE ONE STRAIN IS GONE'
        #raise Exception('kill')



def plot_grid(fig, params):
    grid =map(lambda x: x.strip().split(' '),
              open(au.data_filepath(params['fname'])).readlines())


    grid_rs = zeros((len(grid),len(grid[0])),int) + 200
    if params['command'] == 'DumpLineageGrid':
        grid =array(grid, float)
        grid_colors = zeros(shape(grid),int)
        grid_colors += grid
        cols = ['Mut-Averse','Mut-Prone']
        plotLinCounts(grid)

    elif params['command'] == 'DumpTaskGrid':
        grid_int = array(grid,int)
        grid_colors = zeros(shape(grid_int),int) -1
        while 1:
            nz =nonzero(greater(grid_int,0))
            if len(nz[0]) == 0 : break
            grid_colors[nz[0],nz[1]]+= 1
            grid_int /= 2

        grid = grid_colors #(array(grid, float)) 
        cols,data = au.parse_printed('tasks.dat')
        cols = cols[1:]

    elif params['command'] == 'PrintResourceData':
        grid_int = array(grid,int)
        grid_colors = grid_int
        cols = [str(i) for i in range(max(grid_int)+1)]

    else:
        raise Exception('Grid type not implemented')
    

    #grid = params['grid']
    x = shape(grid)[0]
    y = shape(grid)[1]
    n = x * y

    if x != y:
        print "Grid not square, skipping"
        return



    fig.clear()

    

    ct = mycolors.getct(len(cols))
    nc = len(ct)
    
    xs,ys,rs,cs = [[] for i in range(4)]

    c_lambda = lambda x: x>=0 and ct[x] or [0,0,0]
    
    arr = zeros((x,y,3))
    for i in range(nc):
        arr[nonzero(equal(grid, i))] = ct[i]


    #for i in range(x):
    #    for j in range(y):
    #        grid_colors
    #
    #for i in range(x):
    #    for j in range(y):
    #        xs.append(i)
    #        ys.append(j)
    #        rs.append(grid_rs[i,j])
    #        cs.append(c_lambda( grid_colors[i,j]))
    #ax = fig.add_subplot(111)
    #ax.scatter(xs,ys,rs,cs)

    plt.imshow(arr)
    up.color_legend(fig,ct,cols)
    plt.draw()
    

def plot_ts(fig,params,
            do_grid_resources = True):
    fname = params['fname']
    window = params.get('window',20)
    



    cols, data = au.parse_printed( fname)
    data_dict_unfiltered = {}
    widths_dict = {}

    for i in range(len(cols)):
        c = cols[i]
        data_dict_unfiltered[c] = array(map(lambda x: x[i], data),float)
        widths_dict[c] = i +1

    if 'Update' in cols:
        cols.remove('Update')    

    data_dict = {}
    for c in cols:
        data_dict[c] = data_dict_unfiltered[c]

    name = params['name']
    if name in ['tasks','fitness','all','cdata','res']:
        pass
    else:
        raise Exception('unhandled graph type: '+name)


    nplots = len(cols)
    fig.clear()
    widths = params.get('widths',1)
    last_y = zeros(window)
    ct =mycolors.getct(len(cols))

        
    
    do_fold = False
    if fold_ts and nplots > 9: 
        do_fold = True

    if do_fold:
        all_cols = [cols[0:nplots/2],cols[nplots/2:]]
    else: all_cols = [cols]
    
    
    j = 0
    colors = ct[(nplots/len(all_cols)*j):(nplots/len(all_cols)*(j+1))]
    yvals = zeros(   (len(all_cols[j])  ,window  )   )    
    for i in range(len(all_cols[j])):
        c = all_cols[j][i]            
        n = min(window, len(data_dict[c]))
        y_sm = data_dict[c][-n:]    
        yvals[i,-n:] = y_sm    
        
    seismic(fig, yvals, colors, cols)

    up.color_legend(fig, colors, cols,pos = 3)

    
    print 'Current level: ', cols[0], data_dict[cols[0]][-1]

    plt.draw()
    
    
    if   name == 'res' and do_grid_resources == True:
        grid_resources(cols)
        


    return
    


def grid_resources(labels):
    grids = []
    try:
        for l in labels:
            grids.append(au.parse_res_grid(l))
    except Exception, e:
        if e.args[0] == 'nogrid': return
        else: 
            print 'avida_plots error in grid making'  + str(e.args)
            return
    f = plt.figure(resource_grid_figure)
    f.clear()
    ax = f.add_axes([0,0,1,1])



    ng = len(grids)
    
    do_fold = False
    if fold_grid and ng > 9: 
        do_fold = True

    if do_fold:
        grids2= grids[ng/2:]
        grids = grids[0:ng/2]
        ng /=2
    ct = mycolors.getct(ng)
    nx = ceil(sqrt(ng))
    ny = ceil(sqrt(ng))
    
    sx,sy = shape(grids[0])
    
    m0 = np.max(grids)
    if m0 == 0: m0 = 1

    if do_fold: m1 = np.max(grids2)
    if do_fold: 
        if m1 == 0: m1 = 1

    margin = 3
    if do_fold:
        big_grid = zeros((nx*sx +(nx +1)* margin, ny * sy + (ny +1) * margin,3))
    else:
        big_grid = zeros((nx*sx + (nx+1) *margin, ny * sy + (ny +1)*margin))

    for i in range(ng):
        xofs = mod(i, nx)
        yofs = floor(i / nx) 
        if do_fold:
            big_grid[xofs*(sx)+(xofs+1)*margin:(xofs+1)*sx + ( xofs +1)*margin,
                     yofs*(sy)+(yofs+1)*margin:(yofs+1)*sy +( yofs+1)*margin,0] = grids[i]/m0
            big_grid[xofs*(sx)+(xofs+1)*margin:(xofs+1)*sx +( xofs+1)*margin,
                     yofs*(sy)+(yofs+1)*margin:(yofs+1)*sy +( yofs+1)*margin,2] = greater(grids2[i],presets.lethal_dose/presets.default_use_frac)
        else:
            big_grid[xofs*(sx)+(xofs+1)*margin:(xofs+1)*sx+(xofs+1)*margin,
                     yofs*(sy)+(yofs+1)*margin:(yofs+1)*sy + (yofs+1)*margin] = grids[i]/m0


    #xs,ys,rs = [[] for i in range(3)]
    #for g in grids:
    #    s = shape(g)
    #    gmax = np.max(grids)
    #    if gmax == 0:
    #        gmax = 1
    #    a

#for i in range( s[0]):
        #    for j in range( s[1]):
        #        ys.append(i)
        #        xs.append(j)
        #        rs.append(float(g[i,j]) / gmax / 2 * 1000 )
        #break

    #ax.scatter(xs,ys,rs)
    ax.imshow(big_grid)#,interpolation = 'nearest')
    #ax.set_xlim([0,s[0]])
    #ax.set_ylim([0,s[1]])
    plt.draw()
   # if gmax > 1:
   #     raise Exception()
    
def seismic(fig,
            yvecs_in, 
            colors = None,
            labels = None,
            scale_individual = False):
    
    
    #Seismic only shows absolute values... deal with it.
    yvecs = np.abs(yvecs_in)
    n = shape(yvecs)[0]
    nx = shape(yvecs)[1]
    yofs = arange(n)
   
    big_max = np.max(yvecs)
    all_maxes = np.max(yvecs,1)
    
    ax = fig.add_axes([0,0,1,1],frameon = False)
                      
    xax = arange(nx)
    if not colors:
        colors = ['blue' for i in range(n)]


    nz_lambda = lambda x: x == 0 and 1 or x
    for i in range(n):
        yfrac = 1.0/2.5/n
        ypad = 1.1
        yofs =  (float(i)+.5) / n
        yvec = yvecs[i]
        if scale_individual:
            yvec =yvec/ nz_lambda(all_maxes[i])/ ypad * yfrac 
        else:
            yvec =yvec/ nz_lambda(big_max)/ ypad *yfrac 
       

        ax.fill_between(xax,yvec+yofs,-1*yvec+yofs,
                                 edgecolor = 'none',
                                 facecolor = colors[i])


    
    ax.set_ylim([0,1])
    ax.set_xlim([0,nx])

    

