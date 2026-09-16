**# Tank 1 — Mathematical Proof, Derivation & Verification**

**## Miniature Textile Dyeing Process — Atmospheric Reactive-Cotton Analogue**

****Model scope:**** Tank 1 hydraulic subsystem  

****Software:**** MATLAB / Simulink R2025a  

****Document purpose:**** Professor-facing mathematical proof and verification  

****Status:**** Simulation/design basis; current numerical parameters are assumptions, not hardware measurements.

**---**

**# 1. Purpose and Scope**

This document establishes the mathematical foundation for ****Tank 1**** of the miniature two-tank textile wet-processing project.

The objective is to show, step by step, how the physical Tank 1 system leads to its governing nonlinear ordinary differential equation (ODE), how the equation is implemented in MATLAB/Simulink, and how the implementation is verified using analytical solutions and physical sanity checks.

The present Tank 1 model represents a ****feed/preparation tank**** in an atmospheric reactive-cotton dye-bath analogue.

The current Tank 1 boundary includes:

- inlet pump flow,

- liquid accumulation,

- tank liquid level,

- gravity-driven outlet,

- controllable outlet restriction,

- transfer flow from Tank 1 toward Tank 2.

The current model does ****not**** include:

- Tank 2 dynamics,

- temperature dynamics,

- heater/SSR,

- dye concentration,

- pH,

- chemical reaction kinetics,

- fabric motion,

- dye uptake.

Those belong to later phases.

> ****Important:**** The numerical results in this document are analytical/simulation results obtained from the stated model assumptions. They are ****not experimental hardware measurements****.

**---**

**# 2. Process Basis**

The overall project is a miniature model inspired by ****batch exhaust reactive dyeing of cotton****.

For the future heated Tank 2, the current design basis uses:

\| Quantity | Current basis | Status |

\|---|---:|---|

\| Process analogue | Batch exhaust reactive dyeing of cotton | Design basis |

\| Pressure | approximately 101325 Pa | Atmospheric assumption |

\| Future Tank 2 nominal temperature | 60 °C | Literature-informed design point |

\| Future Tank 2 operating range | 50–70 °C | Design assumption |

\| Future independent temperature trip | 75 °C | Safety assumption |

\| Liquor-ratio basis | 1 kg dry cotton : 10 L liquor | Design basis |

The 60 °C value is ****not claimed to be a universal cotton-dyeing temperature****. Reactive-dye recipes vary with dye chemistry and manufacturer specifications. Therefore, the final physical process temperature must ultimately be selected from the actual dye/process recipe.

The present Tank 1 hydraulic mass balance does not require temperature explicitly.

**---**

**# 3. Overall Two-Tank Architecture**

The intended future process is:

```text

Water / source

     |

     v

  Pump P1

     |

     v

+-----------+

\|  TANK 1   |

\| Feed /    |

\| mixing    |

\| level     |

+-----------+

     |

     | Q12

     v

+-----------+

\|  TANK 2   |

\| Treatment |

\| bath      |

\| Level +   |

\| Temperature

+-----------+

```

Tank 1's outlet flow is called:

\
$$


Q\_{12}

\
$$


because it represents flow from Tank 1 to Tank 2.

Thus, in the eventual coupled model:

\
$$


\boxed{Q\_{in,2}=Q\_{12}}

\
$$


This is the connection between the two tanks.

**---**

**# 4. Tank 1 Physical Model**

Tank 1 is approximated as a vertical cylindrical tank.

```text

              Tank wall

          ┌───────────────┐

          │               │

          │               │

          │\~\~\~\~\~\~\~\~\~\~\~\~\~\~\~│ ← liquid surface

          │               │

       h₁ │               │

          │               │

          └───────────────┘

               bottom

       Diameter = D₁

       Cross-sectional area = A₁

```

The main dynamic variable is the liquid level:

\
$$


\boxed{h\_1(t)}

\
$$


Since the tank has constant cross-sectional area, liquid volume is directly related to level.

Therefore, one hydraulic state variable is sufficient for the current Tank 1 model.

**---**

**# 5. Variables and Sign Conventions**

\| Symbol | Unit | Meaning | Sign convention |

\|---|---|---|---|

\| \\(t\\) | s | Simulation time | Positive forward in time |

\| \\(h\_1\\) | m | Tank 1 liquid level | Measured upward from bottom |

\| \\(V\_1\\) | m³ | Liquid volume in Tank 1 | Positive |

\| \\(A\_1\\) | m² | Tank cross-sectional area | Positive |

\| \\(Q\_{in}\\) | m³/s | Flow entering Tank 1 | Positive into tank |

\| \\(Q\_{12}\\) | m³/s | Flow leaving Tank 1 toward Tank 2 | Positive out of tank |

\| \\(u\_P\\) | % | Pump command | 0–100 % |

\| \\(\alpha\\) | dimensionless | Outlet opening fraction | 0 closed, 1 fully open |

\| \\(C\_dA\\) | m² | Effective discharge coefficient × area | Positive |

\| \\(g\\) | m/s² | Gravitational acceleration | Positive |

The sign convention is therefore:

\
$$


\boxed{\text{Inflow is positive, outflow is negative in the accumulation equation.}}

\
$$


**---**

**# 6. Tank Geometry**

The current miniature Tank 1 design assumes:

\
$$


D\_1=0.200\\,m

\
$$


\
$$


H\_1=0.300\\,m

\
$$


where:

- \\(D\_1\\) = internal tank diameter,

- \\(H\_1\\) = total physical wall height.

For a cylindrical tank:

\
$$


\boxed{A\_1=\frac{\pi D\_1^2}{4}}

\
$$


Substituting:

\
$$


A\_1

=

\frac{\pi(0.200)^2}{4}

\
$$


\
$$


\boxed{A\_1=0.031416\\,m^2}

\
$$


The nominal operating level is:

\
$$


\boxed{h\_{1,sp}=0.160\\,m=160\\,mm}

\
$$


Therefore the nominal volume is:

\
$$


V\_{1,sp}=A\_1h\_{1,sp}

\
$$


\
$$


V\_{1,sp}

=

0.031416(0.160)

\
$$


\
$$


V\_{1,sp}=0.0050265\\,m^3

\
$$


Since:

\
$$


1\\,m^3=1000\\,L

\
$$


we obtain:

\
$$


\boxed{V\_{1,sp}=5.0265\\,L}

\
$$


**---**

**# 7. Physical Limits**

Current simulation/design limits are:

\| Quantity | Value |

\|---|---:|

\| Minimum operating level | 30 mm |

\| Nominal level | 160 mm |

\| High operating/safety level | 250 mm |

\| Physical wall height | 300 mm |

\| Nominal volume | 5.0265 L |

\| High-level volume | 7.854 L |

The 250 mm high-level limit leaves:

\
$$


300-250=50\\,mm

\
$$


of freeboard.

The software level saturation is a ****simulation constraint****, not a physical safety device.

A future physical system should have independent level protection such as float switches.

**---**

**# 8. Modeling Assumptions**

The present Tank 1 model uses the following assumptions:

1\. The liquid is incompressible.

2\. The liquid behaves approximately like water.

3\. Tank 1 is cylindrical.

4\. Tank cross-sectional area is constant.

5\. The tank is open to atmosphere.

6\. The receiving side of the transfer path is treated as approximately atmospheric for the gravity-outlet approximation.

7\. The tank contains one inlet and one outlet.

8\. The liquid level is sufficiently well represented by a single state \\(h\_1\\).

9\. The inlet pump flow is initially approximated as proportional to pump command.

10\. The outlet is approximated using a gravity-driven square-root relationship.

11\. The outlet restriction is represented using an opening fraction \\(\alpha\\).

12\. Detailed tubing pressure losses are neglected in this first model.

13\. Pump dynamics are neglected in the first static flow relationship.

14\. Real pump and valve characteristics will eventually be measured and substituted into the model.

**---**

**# 9. Governing Physical Law: Conservation of Mass**

The fundamental physical law is ****conservation of mass****.

For Tank 1:

\
$$


\boxed{

\text{Accumulation}

=

\text{Inflow}

-

\text{Outflow}

}

\
$$


For an incompressible liquid of approximately constant density, the density cancels and the equation can be expressed as a volume balance:

\
$$


\boxed{

\frac{dV\_1}{dt}=Q\_{in}-Q\_{12}

}

\
$$


This is the starting point of the entire Tank 1 model.

**### Physical interpretation**

If:

\
$$


Q\_{in}>Q\_{12}

\
$$


then more liquid enters than leaves:

\
$$


\boxed{\frac{dV\_1}{dt}>0}

\
$$


and the tank level rises.

If:

\
$$


Q\_{in}<Q\_{12}

\
$$


then more liquid leaves than enters:

\
$$


\boxed{\frac{dV\_1}{dt}<0}

\
$$


and the tank level falls.

If:

\
$$


Q\_{in}=Q\_{12}

\
$$


then:

\
$$


\boxed{\frac{dV\_1}{dt}=0}

\
$$


and the level is steady.

**---**

**# 10. Relationship Between Volume and Level**

For a cylindrical tank:

\
$$


\boxed{V\_1=A\_1h\_1}

\
$$


Because \\(A\_1\\) is constant:

\
$$


\frac{dV\_1}{dt}

=

A\_1\frac{dh\_1}{dt}

\
$$


Substitute this into the conservation equation:

\
$$


A\_1\frac{dh\_1}{dt}

=

Q\_{in}-Q\_{12}

\
$$


Therefore:

\
$$


\boxed{

\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

}

\
$$


This is the basic Tank 1 level dynamic equation.

**---**

**# 11. Inlet Pump Model**

The first simulation uses a simplified pump model.

Let:

- \\(u\_P\\) = pump command in percent,

- \\(Q\_{in,max}\\) = assumed maximum inlet flow.

The initial assumption is a linear relationship:

\
$$


\boxed{

Q\_{in}

=

Q\_{in,max}

\frac{u\_P}{100}

}

\
$$


The assumed maximum pump flow is:

\
$$


Q\_{in,max}=0.60\\,L/min

\
$$


Convert this to SI units:

\
$$


Q\_{in,max}

=

\frac{0.60}{60000}

\
$$


because:

\
$$


1\\,L/min

=

\frac{10^{-3}}{60}\\,m^3/s

\
$$


Therefore:

\
$$


\boxed{

Q\_{in,max}=1.000\times10^{-5}\\,m^3/s

}

\
$$


**### Example: 60% pump command**

\
$$


Q\_{in}

=

0.60(0.60\\,L/min)

\
$$


\
$$


\boxed{

Q\_{in}=0.36\\,L/min

}

\
$$


or:

\
$$


\boxed{

Q\_{in}=6.00\times10^{-6}\\,m^3/s

}

\
$$


**### Important limitation**

The linear relationship is a ****simulation assumption****.

A real pump does not necessarily produce:

\
$$


Q\propto PWM

\
$$


under all operating conditions.

Actual flow depends on:

- pump characteristics,

- pressure/head,

- tubing,

- fittings,

- valve conditions,

- supply voltage,

- PWM implementation.

Therefore, during hardware commissioning, the pump command-to-flow curve should be measured.

**---**

**# 12. Gravity Outlet Model**

Tank 1 transfers liquid toward Tank 2 through a gravity-driven outlet restriction.

The physical driving force is the hydrostatic head created by liquid height.

For a free surface open to atmosphere, a simplified Bernoulli/Torricelli relationship gives outlet velocity:

\
$$


\boxed{

v\_{out}\approx\sqrt{2gh\_1}

}

\
$$


where:

- \\(g\\) = gravitational acceleration,

- \\(h\_1\\) = liquid height above the outlet reference.

For an effective discharge area and discharge coefficient, flow becomes:

\
$$


Q\_{12}

=

C\_dA\sqrt{2gh\_1}

\
$$


If the outlet is partially restricted, introduce:

\
$$


\alpha

\
$$


where:

\
$$


0\leq\alpha\leq1

\
$$


Thus:

\
$$


\boxed{

Q\_{12}

=

\alpha C\_dA\sqrt{2gh\_1}

}

\
$$


**---**

**# 13. Why the Outlet Creates Nonlinearity**

The outlet equation contains:

\
$$


\sqrt{h\_1}

\
$$


Therefore:

\
$$


\boxed{

Q\_{12}\propto\sqrt{h\_1}

}

\
$$


This means the outlet flow is not linearly proportional to level.

For example:

```text

Level increases

      ↓

Hydrostatic head increases

      ↓

√(2gh₁) increases

      ↓

Gravity outlet flow increases

      ↓

Net accumulation decreases

```

Similarly:

```text

Level decreases

      ↓

Hydrostatic head decreases

      ↓

Outlet flow decreases

      ↓

Drain rate becomes smaller

```

This explains why the drain curve is nonlinear.

**---**

**# 14. Final Nonlinear Tank 1 ODE**

Start from:

\
$$


\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

\
$$


Substitute:

\
$$


Q\_{in}

=

Q\_{in,max}\frac{u\_P}{100}

\
$$


and:

\
$$


Q\_{12}

=

\alpha C\_dA\sqrt{2gh\_1}

\
$$


Therefore:

\
$$


\boxed{

\frac{dh\_1}{dt}

=

\frac{

Q\_{in,max}\left(\frac{u\_P}{100}\right)

-

\alpha C\_dA\sqrt{2gh\_1}

}

{A\_1}

}

\
$$


This is the ****governing nonlinear Tank 1 ODE****.

It is nonlinear because:

\
$$


\boxed{\sqrt{h\_1}}

\
$$


appears in the equation.

**---**

**# 15. Numerical Parameter Set**

The current simulation uses:

\| Parameter | Value | Classification |

\|---|---:|---|

\| \\(D\_1\\) | 0.200 m | Assumed |

\| \\(H\_1\\) | 0.300 m | Assumed |

\| \\(A\_1\\) | 0.031416 m² | Derived |

\| \\(h\_{1,sp}\\) | 0.160 m | Assumed |

\| \\(V\_{1,sp}\\) | 5.0265 L | Derived |

\| \\(h\_{min}\\) | 0.030 m | Assumed limit |

\| \\(h\_{high}\\) | 0.250 m | Assumed limit |

\| \\(Q\_{in,max}\\) | 0.60 L/min | Assumed |

\| \\(C\_dA\\) | \\(4.23\times10^{-6}\\) m² | Assumed |

\| \\(\alpha\_{nominal}\\) | 0.65 | Assumed |

\| \\(g\\) | 9.81 m/s² | Established constant |

The current parameter file intentionally distinguishes assumed parameters from measured parameters.

**---**

**# 16. Steady-State Proof**

A steady-state condition means:

\
$$


\boxed{

\frac{dh\_1}{dt}=0

}

\
$$


From:

\
$$


\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

\
$$


we require:

\
$$


Q\_{in}-Q\_{12}=0

\
$$


Therefore:

\
$$


\boxed{

Q\_{in}=Q\_{12}

}

\
$$


This is the physical equilibrium condition.

**---**

**# 17. Calculate the Nominal Outlet Flow**

At:

\
$$


h\_{1,sp}=0.160\\,m

\
$$


and:

\
$$


\alpha=0.65

\
$$


with:

\
$$


C\_dA=4.23\times10^{-6}\\,m^2

\
$$


and:

\
$$


g=9.81\\,m/s^2

\
$$


the outlet flow is:

\
$$


Q\_{12}

=

0.65(4.23\times10^{-6})

\sqrt{2(9.81)(0.160)}

\
$$


Therefore:

\
$$


\boxed{

Q\_{12}\approx4.8715\times10^{-6}\\,m^3/s

}

\
$$


Convert to L/min:

\
$$


Q\_{12}

=

4.8715\times10^{-6}\times60000

\
$$


\
$$


\boxed{

Q\_{12}\approx0.29229\\,L/min

}

\
$$


**---**

**# 18. Calculate the Required Pump Command**

At equilibrium:

\
$$


Q\_{in}=Q\_{12}=0.29229\\,L/min

\
$$


The assumed pump maximum is:

\
$$


Q\_{in,max}=0.60\\,L/min

\
$$


Using:

\
$$


Q\_{in}

=

Q\_{in,max}\frac{u\_P}{100}

\
$$


we obtain:

\
$$


u\_{P,eq}

=

100\frac{Q\_{12}}{Q\_{in,max}}

\
$$


Therefore:

\
$$


u\_{P,eq}

=

100\frac{0.29229}{0.60}

\
$$


\
$$


\boxed{

u\_{P,eq}\approx48.715\%

}

\
$$


Thus:

\
$$


\boxed{

h\_1=160\\,mm,\quad

Q\_{in}=Q\_{12}=0.29229\\,L/min,\quad

u\_P\approx48.715\%

}

\
$$


is the calculated nominal equilibrium under the current assumptions.

**---**

**# 19. Equilibrium Verification**

At the calculated equilibrium:

\
$$


Q\_{in}=Q\_{12}

\
$$


Therefore:

\
$$


\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

\
$$


\
$$


=

\frac{0}{A\_1}

\
$$


\
$$


\boxed{

\frac{dh\_1}{dt}=0

}

\
$$


The MATLAB numerical diagnostic returned approximately:

\
$$


2.6962\times10^{-20}\\,m/s

\
$$


This is effectively zero.

The tiny value is floating-point numerical round-off rather than physical level movement.

**---**

**# 20. Verification Test 1 — Closed Outlet Filling**

**## Initial conditions**

\
$$


h\_0=0.060\\,m

\
$$


\
$$


u\_P=40\%

\
$$


\
$$


\alpha=0

\
$$


Because the outlet is closed:

\
$$


Q\_{12}=0

\
$$


Therefore:

\
$$


\frac{dh\_1}{dt}

=

\frac{Q\_{in}}{A\_1}

\
$$


Since the inlet flow is constant:

\
$$


\frac{dh\_1}{dt}=constant

\
$$


Integrating:

\
$$


\boxed{

h\_1(t)

=

h\_0+\frac{Q\_{in}}{A\_1}t

}

\
$$


Thus the level must rise ****linearly****.

**### Numerical result**

\| Quantity | Result |

\|---|---:|

\| Initial level | 60 mm |

\| Pump command | 40 % |

\| Outlet opening | 0 |

\| Duration | 10 min |

\| Final level | ≈136.4 mm |

\| Maximum numerical error | ≈\\(1.69\times10^{-12}\\) mm |

The numerical ODE solution and analytical solution overlap.

Therefore the implementation correctly reproduces the expected conservation-law result for the closed-outlet case.

**---**

**# 21. Verification Test 2 — Nonlinear Gravity Drain**

**## Initial conditions**

\
$$


h\_0=0.160\\,m

\
$$


\
$$


u\_P=0\%

\
$$


\
$$


\alpha=0.65

\
$$


With the pump off:

\
$$


Q\_{in}=0

\
$$


Therefore:

\
$$


\frac{dh\_1}{dt}

=

-\frac{\alpha C\_dA\sqrt{2gh\_1}}{A\_1}

\
$$


Define:

\
$$


k=\alpha C\_dA\sqrt{2g}

\
$$


Then:

\
$$


\boxed{

\frac{dh\_1}{dt}

=

-\frac{k}{A\_1}\sqrt{h\_1}

}

\
$$


**---**

**# 22. Step-by-Step Analytical Solution of the Drain Test**

Start with:

\
$$


\frac{dh\_1}{dt}

=

-\frac{k}{A\_1}\sqrt{h\_1}

\
$$


Separate variables:

\
$$


\frac{dh\_1}{\sqrt{h\_1}}

=

-\frac{k}{A\_1}dt

\
$$


Since:

\
$$


\frac{1}{\sqrt{h\_1}}=h\_1^{-1/2}

\
$$


we integrate:

\
$$


\int h\_1^{-1/2}dh\_1

=

-\frac{k}{A\_1}\int dt

\
$$


Therefore:

\
$$


2\sqrt{h\_1}

=

-\frac{k}{A\_1}t+C

\
$$


At:

\
$$


t=0,\qquad h\_1=h\_0

\
$$


so:

\
$$


C=2\sqrt{h\_0}

\
$$


Hence:

\
$$


2\sqrt{h\_1}

=

-\frac{k}{A\_1}t+2\sqrt{h\_0}

\
$$


Divide by 2:

\
$$


\sqrt{h\_1}

=

\sqrt{h\_0}

-

\frac{k}{2A\_1}t

\
$$


Square both sides:

\
$$


\boxed{

h\_1(t)

=

\left[

\sqrt{h\_0}

-

\frac{k}{2A\_1}t

\right]^2

}

\
$$


until the physical level reaches zero.

This is the analytical nonlinear draining solution.

**### Numerical result**

\| Quantity | Result |

\|---|---:|

\| Initial level | 160 mm |

\| Pump command | 0 % |

\| Outlet opening | 65 % |

\| Duration | 30 min |

\| Final level | ≈2.61 mm |

\| Maximum numerical error | ≈\\(8.33\times10^{-14}\\) mm |

Again, the numerical ODE solution overlaps the analytical solution.

**---**

**# 23. Verification Test 3 — Balanced Flows**

The third test starts at:

\
$$


h\_1=160\\,mm

\
$$


and uses:

\
$$


u\_P=48.715\%

\
$$


with:

\
$$


\alpha=0.65

\
$$


At this condition:

\
$$


Q\_{in}=Q\_{12}

\
$$


Therefore:

\
$$


\frac{dh\_1}{dt}=0

\
$$


The simulation shows the level remaining at approximately:

\
$$


\boxed{160\\,mm}

\
$$


for the complete test duration.

This verifies the calculated equilibrium.

**---**

**# 24. Summary of Verification Results**

\| Test | Expected behavior | Simulation result | Status |

\|---|---|---|---|

\| Test 1: outlet closed | Level rises linearly | ≈60 → 136.4 mm | Pass |

\| Test 2: pump off | Level falls nonlinearly | ≈160 → 2.61 mm | Pass |

\| Test 3: balanced flows | Level remains constant | ≈160 mm | Pass |

The calculated numerical errors were:

\
$$


\boxed{

e\_{fill}\approx1.69\times10^{-12}\\,mm

}

\
$$


\
$$


\boxed{

e\_{drain}\approx8.33\times10^{-14}\\,mm

}

\
$$


\
$$


\boxed{

e\_{equilibrium}\approx0\\,mm

}

\
$$


These are effectively zero at the scale of this simulation.

**---**

**# 25. Interpretation of the Verification Plot**

The verification plot contains three experiments.

**### Test 1**

The blue ODE curve and black dashed analytical curve overlap.

Meaning:

> The numerical ODE correctly reproduces constant-volume accumulation when the outlet is closed.

**### Test 2**

The blue ODE curve and black dashed nonlinear analytical curve overlap.

Meaning:

> The numerical ODE correctly reproduces gravity-driven nonlinear draining.

**### Test 3**

The blue curve remains on the nominal equilibrium line.

Meaning:

> The calculated inlet and outlet flows balance, giving zero net volume accumulation.

**---**

**# 26. Unit / Dimensional Consistency Proof**

The governing equation is:

\
$$


\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

\
$$


Flow has units:

\
$$


[Q]=m^3/s

\
$$


Area has units:

\
$$


[A\_1]=m^2

\
$$


Therefore:

\
$$


\left[

\frac{Q}{A\_1}

\right]

=

\frac{m^3/s}{m^2}

\
$$


\
$$


\boxed{

=

m/s

}

\
$$


which is exactly the unit of:

\
$$


\frac{dh\_1}{dt}

\
$$


Now check the outlet equation:

\
$$


Q\_{12}

=

\alpha C\_dA\sqrt{2gh\_1}

\
$$


where:

\
$$


[\alpha]=1

\
$$


\
$$


[C\_dA]=m^2

\
$$


and:

\
$$


[gh\_1]

=

\frac{m}{s^2}m

=

\frac{m^2}{s^2}

\
$$


so:

\
$$


[\sqrt{gh\_1}]

=

m/s

\
$$


Therefore:

\
$$


[Q\_{12}]

=

m^2(m/s)

\
$$


\
$$


\boxed{

[Q\_{12}]=m^3/s

}

\
$$


Thus the outlet equation is dimensionally consistent.

**---**

**# 27. Physical Sanity Checks**

The model should always satisfy the following logic:

**### Case 1**

\
$$


Q\_{in}>Q\_{12}

\
$$


therefore:

\
$$


\boxed{\frac{dh\_1}{dt}>0}

\
$$


Tank level rises.

**### Case 2**

\
$$


Q\_{in}<Q\_{12}

\
$$


therefore:

\
$$


\boxed{\frac{dh\_1}{dt}<0}

\
$$


Tank level falls.

**### Case 3**

\
$$


Q\_{in}=Q\_{12}

\
$$


therefore:

\
$$


\boxed{\frac{dh\_1}{dt}=0}

\
$$


Tank level is steady.

**### Case 4**

\
$$


\alpha=0

\
$$


therefore:

\
$$


\boxed{Q\_{12}=0}

\
$$


The outlet is closed.

**### Case 5**

\
$$


h\_1\uparrow

\
$$


therefore:

\
$$


\sqrt{h\_1}\uparrow

\
$$


and:

\
$$


\boxed{Q\_{12}\uparrow}

\
$$


Gravity outlet flow increases.

**### Case 6**

\
$$


h\_1\downarrow

\
$$


therefore:

\
$$


Q\_{12}\downarrow

\
$$


and the gravity drain becomes slower.

These are physically expected behaviors.

**---**

**# 28. MATLAB Implementation**

The MATLAB implementation directly follows the derived equations.

The calculation sequence is:

```text

Pump command

     |

     v

Calculate Qin

     |

     |

     +--------------------+

                          |

                          v

                    Qin − Q12

                          |

                          v

                        / A1

                          |

                          v

                       dh1/dt

                          |

                          v

                      Integrator

                          |

                          v

                         h1

                          |

                          v

                     sqrt(h1)

                          |

                          v

                 gravity outlet Q12

                          |

                          +---------- back to Qin − Q12

```

The ODE calculation is:

\
$$


Q\_{in}

=

Q\_{in,max}\frac{u\_P}{100}

\
$$


\
$$


Q\_{12}

=

\alpha C\_dA\sqrt{2gh\_1}

\
$$


\
$$


\boxed{

\frac{dh\_1}{dt}

=

\frac{Q\_{in}-Q\_{12}}{A\_1}

}

\
$$


**---**

**# 29. Simulink Implementation**

The Simulink model is a graphical representation of the same mathematics.

The main blocks correspond to:

\| Simulink block | Mathematical meaning |

\|---|---|

\| Pump PWM (%) | \\(u\_P\\) |

\| Pump flow Qin | \\(Q\_{in,max}u\_P/100\\) |

\| Valve opening | \\(\alpha\\) |

\| CdA max | \\(C\_dA\\) |

\| sqrt(h) | \\(\sqrt{h\_1}\\) |

\| sqrt(2g) | \\(\sqrt{2g}\\) |

\| Outlet Q12 | \\(\alpha C\_dA\sqrt{2gh\_1}\\) |

\| Qin minus Q12 | Net volume accumulation |

\| 1 Tank area | Division by \\(A\_1\\) |

\| Tank level h | Integration of \\(dh\_1/dt\\) |

\| Level h (mm) | Conversion \\(1000h\_1\\) |

\| Flow scopes | Conversion to L/min |

The mathematical structure is therefore:

\
$$


u\_P

\rightarrow

Q\_{in}

\
$$


and:

\
$$


h\_1

\rightarrow

\sqrt{h\_1}

\rightarrow

Q\_{12}

\
$$


and:

\
$$


Q\_{in}-Q\_{12}

\rightarrow

\frac{1}{A\_1}

\rightarrow

\frac{dh\_1}{dt}

\rightarrow

\int

\rightarrow

h\_1

\
$$


This demonstrates that the Simulink model is not an independent approximation; it is the graphical implementation of the derived physical ODE.

**---**

**# 30. Level Constraints in the Simulation**

The simulation constrains the physical level between:

\
$$


0\leq h\_1\leq0.300\\,m

\
$$


This corresponds to:

\
$$


0\leq h\_1\leq300\\,mm

\
$$


The preferred operating region is:

\
$$


0.030\leq h\_1\leq0.250\\,m

\
$$


or:

\
$$


\boxed{30\leq h\_1\leq250\\,mm}

\
$$


The upper simulation boundary prevents the mathematical state from exceeding the physical tank wall.

However:

> A software saturation limit is not an independent hardware safety device.

The physical prototype should use independent protection.

**---**

**# 31. Assumed Parameters vs Experimental Parameters**

A critical engineering distinction is required.

**## Currently assumed**

- tank diameter,

- tank wall height,

- nominal level,

- pump maximum flow,

- pump PWM-to-flow relationship,

- outlet \\(C\_dA\\),

- valve opening,

- operating limits.

**## Eventually measured**

- actual tank dimensions,

- actual pump PWM-to-flow curve,

- actual pump head-flow behavior,

- actual outlet flow versus level,

- actual valve characteristic,

- tubing pressure losses,

- sensor characteristics.

The parameter file should therefore maintain two categories:

```text

ASSUMED

    |

    +-- Used now for simulation

MEASURED

    |

    +-- Empty until physical commissioning

```

The current project deliberately leaves measured fields empty until genuine physical data are collected.

**---**

**# 32. Experimental Identification Required Later**

When hardware is available, the following measurements should be performed.

**## Pump calibration**

For several commands:

\
$$


u\_P=20\%,40\%,60\%,80\%,100\%

\
$$


measure:

\
$$


Q\_{in}

\
$$


and construct:

\
$$


Q\_{in}=f(u\_P)

\
$$


The current linear equation can then be replaced by the measured relationship.

**## Outlet identification**

At several levels and valve positions, measure:

\
$$


Q\_{12}=f(h\_1,\alpha)

\
$$


This can be used to identify or refine:

\
$$


C\_dA

\
$$


or a more detailed outlet model.

Only after these experiments should the parameters be described as experimentally identified.

**---**

**# 33. Limitations of the Current Tank 1 Model**

The current model is intentionally simple enough for a minor project while retaining the key nonlinear physics.

Its main limitations are:

1\. Pump flow is assumed linear with command.

2\. Pump head-flow behavior is not explicitly modeled.

3\. Tubing pressure losses are neglected.

4\. Valve hysteresis is not modeled.

5\. Detailed outlet geometry is represented by a single effective \\(C\_dA\\).

6\. Tank cross-sectional area is assumed constant.

7\. The liquid is treated as incompressible.

8\. Temperature does not affect the current hydraulic equation.

9\. Dye concentration is not modeled.

10\. Tank 2 is not yet included.

11\. No experimental parameter identification has yet been performed.

These are known simplifications rather than hidden assumptions.

**---**

**# 34. Why This Model Is Suitable as the Tank 1 Foundation**

The model has several useful properties.

**### It is physically derived**

It begins with:

\
$$


\boxed{\text{Conservation of volume}}

\
$$


rather than an arbitrary fitted equation.

**### It retains nonlinearity**

The gravity outlet uses:

\
$$


\boxed{\sqrt{h\_1}}

\
$$


rather than silently replacing the physical relationship with a linear approximation.

**### It is understandable**

Every Simulink block corresponds to a recognizable physical or mathematical operation.

**### It can be experimentally calibrated**

The uncertain parameters are clearly identified so they can later be replaced by measurements.

**### It connects naturally to Tank 2**

The Tank 1 outlet:

\
$$


\boxed{Q\_{12}}

\
$$


becomes the Tank 2 inlet.

**---**

**# 35. Final Mathematical Proof**

The complete derivation can be summarized as follows.

**### Step 1 — Conservation of liquid volume**

\
$$


\boxed{

\frac{dV\_1}{dt}=Q\_{in}-Q\_{12}

}

\
$$


**### Step 2 — Cylindrical geometry**

\
$$


\boxed{

V\_1=A\_1h\_1

}

\
$$


**### Step 3 — Differentiate**

\
$$


\boxed{

\frac{dV\_1}{dt}

=

A\_1\frac{dh\_1}{dt}

}

\
$$


**### Step 4 — Substitute into conservation**

\
$$


\boxed{

A\_1\frac{dh\_1}{dt}

=

Q\_{in}-Q\_{12}

}

\
$$


**### Step 5 — Pump relationship**

\
$$


\boxed{

Q\_{in}

=

Q\_{in,max}\frac{u\_P}{100}

}

\
$$


**### Step 6 — Gravity outlet relationship**

\
$$


\boxed{

Q\_{12}

=

\alpha C\_dA\sqrt{2gh\_1}

}

\
$$


**### Step 7 — Substitute both flow equations**

\
$$


A\_1\frac{dh\_1}{dt}

=

Q\_{in,max}\frac{u\_P}{100}

-

\alpha C\_dA\sqrt{2gh\_1}

\
$$


**### Step 8 — Divide by tank area**

\
$$


\boxed{

\frac{dh\_1}{dt}

=

\frac{

Q\_{in,max}\left(\frac{u\_P}{100}\right)

-

\alpha C\_dA\sqrt{2gh\_1}

}

{A\_1}

}

\
$$


Therefore:

\
$$


\boxed{

\boxed{

\frac{dh\_1}{dt}

=

\frac{

Q\_{in,max}\left(\frac{u\_P}{100}\right)

-

\alpha C\_dA\sqrt{2gh\_1}

}

{A\_1}

}

}

\
$$


This is the final nonlinear Tank 1 hydraulic model.

**---**

**# 36. Final Verification Statement**

The Tank 1 model has been verified mathematically using three independent checks:

1\. ****Closed outlet filling:**** numerical ODE agrees with the exact linear filling solution.

2\. ****Gravity draining:**** numerical ODE agrees with the derived nonlinear analytical solution.

3\. ****Balanced flow:**** calculated inlet flow equals outlet flow, producing zero level-rate at the nominal operating point.

The verification results are:

\
$$


\boxed{

e\_{fill}\approx1.69\times10^{-12}\\,mm

}

\
$$


\
$$


\boxed{

e\_{drain}\approx8.33\times10^{-14}\\,mm

}

\
$$


\
$$


\boxed{

e\_{equilibrium}\approx0\\,mm

}

\
$$


Therefore, ****the MATLAB implementation is mathematically consistent with the stated Tank 1 equations and assumptions****.

This statement should not be interpreted as experimental validation of the assumed pump and outlet parameters. Physical validation will require commissioning measurements.

**---**

**# 37. Short Explanation for Professor / Viva**

If asked:

**### "How did you derive your Tank 1 model?"**

Answer:

> We started from conservation of liquid volume. The accumulation of liquid in Tank 1 must equal the inlet flow minus the outlet flow.

\
$$


\frac{dV\_1}{dt}=Q\_{in}-Q\_{12}

\
$$


> Since Tank 1 is modeled as a cylindrical tank with constant cross-sectional area,

\
$$


V\_1=A\_1h\_1

\
$$


> so:

\
$$


A\_1\frac{dh\_1}{dt}=Q\_{in}-Q\_{12}

\
$$


> The pump inlet was initially modeled as proportional to its command:

\
$$


Q\_{in}=Q\_{in,max}\frac{u\_P}{100}

\
$$


> The gravity outlet was modeled using the Torricelli/Bernoulli square-root relationship:

\
$$


Q\_{12}=\alpha C\_dA\sqrt{2gh\_1}

\
$$


> Substituting these into the mass balance gives our nonlinear Tank 1 ODE:

\
$$


\boxed{

\frac{dh\_1}{dt}

=

\frac{

Q\_{in,max}(u\_P/100)

-

\alpha C\_dA\sqrt{2gh\_1}

}

{A\_1}

}

\
$$


> The model is nonlinear because the gravity outlet flow contains \\(\sqrt{h\_1}\\). We then verified the numerical implementation using a linear filling test, a nonlinear draining test, and an equilibrium test.

**---**

**# 38. Next Engineering Stage**

Tank 1 should now be treated as the verified ****hydraulic foundation**** of the project.

The next logical stage is:

```text

Verified Tank 1 nonlinear model

             ↓

Tank 1 level controller

             ↓

PI control

             ↓

Disturbance testing

             ↓

Transfer-flow behavior

             ↓

Tank 2 hydraulic model

             ↓

Tank 2 thermal model

             ↓

Coupled two-tank model

```

The next controller should therefore be designed around the verified nonlinear plant rather than replacing the nonlinear plant with an arbitrary linear model.

**---**

**# Appendix A — Supporting Project Files**

\| File | Purpose |

\|---|---|

\| \`tank1\_parameters.m\` | Central parameter source |

\| \`tank1\_ode.m\` | Nonlinear Tank 1 ODE |

\| \`tank1\_simulate\_and\_verify.m\` | Verification tests |

\| \`build\_tank1\_simulink.m\` | Simulink model builder |

\| \`tank1\_hydraulic\_model.slx\` | Tank 1 Simulink model |

\| \`tank1\_verification\_results.csv\` | Numerical verification results |

\| \`tank1\_verification\_plot.png\` | Verification figure |

\| \`TANK1\_MODEL\_NOTE.md\` | Tank 1 design basis and assumptions |

**---**

**# Appendix B — Key Numerical Results**

\
$$


\boxed{A\_1=0.031416\\,m^2}

\
$$


\
$$


\boxed{V\_{1,sp}=5.0265\\,L}

\
$$


\
$$


\boxed{h\_{1,sp}=160\\,mm}

\
$$


\
$$


\boxed{Q\_{12,sp}=0.29229\\,L/min}

\
$$


\
$$


\boxed{u\_{P,eq}=48.715\%}

\
$$


\
$$


\boxed{Q\_{in,max}=0.60\\,L/min}

\
$$


\
$$


\boxed{h\_{high}=250\\,mm}

\
$$


**---**

**## Document Status**

****Tank 1 mathematical derivation:**** Complete  

****Tank 1 nonlinear ODE:**** Complete  

****Analytical verification:**** Complete  

****Simulink representation:**** Complete/corrected source available  

****Experimental validation:**** Not yet performed  

****Hardware parameter identification:**** Pending  

****Tank 2 coupling:**** Future stage
