import cfg_avida as ca
import avida_utils as au
import re
from numpy import *

default_x = 50
default_y = 50
default_gens = 10000

uni_inflow_multiplier = .05
uni_inflow_rate = default_x * default_y * uni_inflow_multiplier
#uni_inflow_rate = 10000
uni_outflow_rate = .01
#this implies a steady state concentration of 10000
default_use_frac = .9

steady_state = uni_inflow_multiplier / uni_outflow_rate
#value per usage only applies at bursts!
value_per_usage = steady_state * default_use_frac
value_multiplier =16/ value_per_usage

#and every operation will thus convert ~10 units

mu0 = .03
deltamu = .015

#since each operation produces ~10, try setting the lethal dose to 50
enable_biproducts = True
biproduct_last = True

#since value_per
lethal_biproduct = True
conversion = 3.0
expected_burst_dose = value_per_usage * conversion
lethal_dose =  expected_burst_dose * 1
#trigger a chain reaction?
death_chain_reaction = True
#chain reaction spread speed
death_chain_mag = 3
biproduct_outflow = .25

kmut = 1
kdiv = 1.5


default_ygrav = .85
default_xgrav = 0

default_xdiffuse = 1
default_ydiffuse = 1
xdiffuse_grav = .75
ydiffuse_grav = .3


#Do nothing, create a genesis file just by
#copying over the default copy.
#
#Do not add any action events.
#

def SetMu(muval):
    global mu0
    mu0 = muval

def SetDMu(dval):
    global deltamu
    deltamu = dval

def shift(seq, n):
    n = n % len(seq)
    return seq[n:] + seq[:n]

def untouched(name,  eve_fname, org_fname, ana_fname,   env_fname, ins_fname,  gen_name):

    genesis = ca.make_gen(name,
                          {},
                          gen_name)


#Create a genesis fie and add action events:
#1: Kill off the ancestor
#2: Set mutation rates per site
#3: Re-Inject into strains with fixed mutation rates.
def differential_mut(name, eve_fname, org_fname, ana_fname, env_fname,  ins_fname, gen_name):
    #CONFIG PARAMETERS
    mut_rate_source = 2
    x = default_x
    y = default_y
    params_dict = {'MUT_RATE_SOURCE':2,
                   'WORLD_X':x,
                   'WORLD_Y':y,
                   'WORLD_GEOMETRY':2,
                   'ENVIRONMENT_FILE':env_fname,
                   'ANALYZE_FILE':ana_fname,
                   'EVENT_FILE':eve_fname,
                   'INST_SET':ins_fname,
                   'START_CREATURE':org_fname,
                   'DIVIDE_INS_PROB':0.0,
                   'DIVIDE_DEL_PROB':0.0,
                   'COPY_MUT_PROB':0.00}

    genesis = ca.make_gen(name,\
                          params_dict,\
                          gen_name)
    #Create a genome and a complementing genome
    genome = au.genesis_seqs(genesis)
    seqprime = genome
    repeats = re.search(re.compile('c{3,}'),seqprime).group()
    seqprime =seqprime.replace(repeats,repeats.replace('c','b'))
    org_fname2 = au.save_genome(genesis,  seqprime, org_fname + '.comp')
    n = x * y
    ntot = x*y
    nofs = ntot/2
    #STERILIZE 
    ca.alter_eve(eve_fname, 'i KillRectangle 0 0 '+str(x) + ' ' + str(y))    
    #SET MUTATION PROBS

    highmut_strings = ['i SetMutProb COPY_MUT '+str((mu0 - deltamu)*kmut) + ' 1 '+str(nofs),
                       'i SetMutProb DIVIDE_INS '+str((mu0 - deltamu)*kdiv) + ' 1 '+str(nofs),
                       'i SetMutProb DIVIDE_DEL '+str((mu0 - deltamu)*kdiv) + ' 1 '+str(nofs)]

    lowmut_strings =  ['i SetMutProb COPY_MUT '+str((mu0 + deltamu)*kmut) + ' ' + str(nofs+1) + ' ' +str(ntot),
                       'i SetMutProb DIVIDE_INS '+str((mu0 + deltamu)*kdiv) + ' ' + str(nofs+1) + ' ' +str(ntot),
                       'i SetMutProb DIVIDE_DEL '+str((mu0 + deltamu)*kdiv) + ' ' + str(nofs+1) + ' ' +str(ntot)]

    for s in highmut_strings:
        ca.alter_eve(eve_fname, s)

    for s in lowmut_strings:
        ca.alter_eve(eve_fname, s)

    #INJECT
    ca.alter_eve(eve_fname,   
                 'i InjectRange '+org_fname+' 1 '+str(nofs)+' -1 0')
    ca.alter_eve(eve_fname,   
                 'i InjectRange '+org_fname+' '+str(nofs+1)+ ' ' +str(ntot) +' -1 1')

    #get a default set of resources, tasks, rxns and corresponding  params

    task_names, res_names, resource_ropts = get_resources()
    task_names_b, res_names_b, resource_ropts_b = get_resources(distribution = 'gravity',
                                                                ygrav = default_ygrav,
                                                                outflow = biproduct_outflow,
                                                                inflow = 0, 
                                                                kind = 'byproduct')


    if enable_biproducts:
        if biproduct_last: biproducts=  shift(res_names_b, -1)
        else: biproducts = res_names_b
    else:
        biproducts = None
    rxn_names, rxn_popts, rxn_ropts = get_reactions(res_names,
                                            
        conversion = conversion,
                                                    product_names = biproducts)

    if death_chain_reaction: b_prods = res_names_b
    else:b_prods = res_names

                                   
 
    rslines = au.resource_lines(res_names, resource_ropts)
    rxlines = au.reaction_lines(rxn_names, task_names,rxn_popts,rxn_ropts)


    ca.append_lines(env_fname, rslines)
    
    

    if enable_biproducts:
        rxn_names_b, rxn_popts_b, rxn_ropts_b = get_reactions(res_names_b, 
                                                              lethal = lethal_biproduct,
                                                              min_count = lethal_dose,
                                                              product_names = b_prods,
                                                              conversion = death_chain_mag,
                                                              bonus_type = 'mult',
                                                              values = [0 for i in res_names])
        rslines_b = au.resource_lines(res_names_b, resource_ropts_b)
        rxlines_b = au.reaction_lines(rxn_names_b, task_names_b,rxn_popts_b,rxn_ropts_b)
        ca.append_lines(env_fname, rslines_b)
        ca.append_lines(env_fname, rxlines_b)
    
    ca.append_lines(env_fname, rxlines)

    #EXIT
    ca.alter_eve(eve_fname, 'g ' + str(default_gens) + ' Exit')



def get_resources(inflow = uni_inflow_rate,
                  outflow = uni_outflow_rate,
                  distribution = 'uniform',
                  kind = 'default',
                  ygrav = default_ygrav):

    task_resources = get_task_resource_list(kind = kind)
    task_names = map(lambda x: x[0], task_resources)
    res_names =map(lambda x: x[1], task_resources)
    #get options for the established names and values
    n = len(res_names)
    resource_ropts,rxn_popts,rxn_ropts = [[] for i in range(3)]

    if distribution == 'uniform':
        for i in range(n):
            resource_ropts.append(getuni_ropts(inflow, outflow))
    elif distribution== 'none':
        for i in range(n):
            resource_ropts.append(getuni_ropts(0, outflow   ))
    elif distribution== 'gravity':
        for i in range(n):
            resource_ropts.append(getgrav_ropts(inflow, outflow ,ygrav = ygrav   ))

    return task_names, res_names, resource_ropts

def get_task_resource_list(kind = 'default'):
     default_task_resources = [['not','resNOT'],\
                          ['nand','resNAND'],\
                          ['and','resAND'],\
                          ['orn','resORN'],\
                          ['or','resOR'],\
                          ['andn','resANDN'],\
                          ['nor','resNOR'],\
                          ['xor','resXOR'],\
                          ['equ','resEQU']]   
     if kind == 'default':
         res = default_task_resources
     elif kind =='byproduct':
         res = []
         for r in default_task_resources:
             row = r
             row[1] += 'B'
             res.append(row)
     return res

def get_reactions(res_names,
                  values = None,
                  lethal = False,
                  product_names = None,
                  min_count = 0,
                  conversion = 1,
                  bonus_type = 'pow'):
    if not values: values = default_rxvals()
    rxn_popts = []
    rxn_ropts = []
    rxn_names = []
    for i in range(len(res_names)):
        if product_names: product_name = product_names[i] 
        else: product_name = None
        rxn_popts.append(getrxn_popts(res_names[i],values[i], lethal = lethal,
                                      product_name = product_name,
                                      conversion = conversion,
                                      bonus_type = bonus_type))
        rxn_ropts.append(getrxn_ropts(min_count = min_count))
        rxn_names.append(res_names[i].upper())
    return rxn_names, rxn_popts, rxn_ropts

#reaction values normalized by expected steady state 
#concentrations
def default_rxvals():
    default_vals = sqrt(array([1,1,2,2,4,4,8,8,16])) * value_multiplier
    
    return default_vals
    

def getgrav_ropts(inflow, outflow,xgrav = 0,ygrav = .25):
    xdiffuse = .5
    ydiffuse = .25
    x = default_x
    y = default_y

    #write resource lines:
    resource_opts= [['inflow',inflow],\
                        ['outflow',outflow],\
                        ['geometry','grid'],\
                        ['inflowx1' ,  0], \
                        ['inflowx2' ,  x-1],\
                        ['inflowy1' ,  0],\
                        ['inflowy2' ,  0],\
                        ['outflowx1' , 0 ],\
                        ['outflowx2' , x-1],\
                        ['outflowy1' , y - 1 ],\
                        ['outflowy2' , y - 1],\
                        ['ygravity'  , ygrav],\
                        ['xgravity'  ,xgrav],\
                        ['ydiffuse',ydiffuse],\
                        ['xdiffuse',xdiffuse]]

    #convert quantities to strs
    resource_opts = [[ "%s" % e for e in l] for l in resource_opts]
    return resource_opts

def getuni_ropts(inflow, outflow):
    x = default_x
    y = default_y


    #write resource lines:
    resource_opts= [['inflow',inflow],\
                        ['outflow',outflow],\
                        ['geometry','torus'],\
                        ['inflowx1' ,  0], \
                        ['inflowx2' ,  x-1],\
                        ['inflowy1' ,  0],\
                        ['inflowy2' ,  y-1],\
                        ['outflowx1',0],
                    ['outflowx2',x-1],
                    ['outflowy1',0],
                    ['outflowy2',y-1]]
    resource_opts = [[ "%s" % e for e in l] for l in resource_opts]
    return resource_opts



def getrxn_popts(resource, 
                 value = 1,
                 frac = default_use_frac,
                 lethal = False,
                 product_name = None,
                 conversion = 1,
                 bonus_type = 'pow'):

    opts = [['resource',resource],
            ['value',value],
            ['frac',frac],
            ['type',bonus_type],
            ['conversion',conversion]]
    
    if product_name:
        opts.append(['product',product_name])
    if lethal:
        opts.append(['lethal',1])

    #convert quantities to strs
    opts = [[ "%s" % e for e in l] for l in opts]
    return opts

def getrxn_ropts(min_count = 0):
    opts = [['min_count',min_count]]
    
    #convert quantities to strs
    opts = [[ "%s" % e for e in l] for l in opts]
    return opts



def periodic_res(eve_fname, period, res_name, injection):
    ca.alter_eve(eve_fname, period + ' ' + 'SetCellResource ' +'0' + ' ' +res_name+ ' ' + str(injection)) 
