================ KERNEL TRACE ================
Warning: Malfored trace stack (unclosed blocks).
⊢ Inferring sort of declaration's type
                                                  ▼ inferExpr @ 0 : Sort((0 + 1))
                                                  ⊢ Checking declaration's type is a valid type
                                                  ▼ ensureSort: VSort (((0 + 1) + 1))
                                                    ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                  ⊢ Inferring type of declaration's body
                                                  ▼ inferExpr @ 0 : Sort(0)
                                                  ▼ evalM: Sort((0 + 1))
                                                    ⊢ LocalEnv is []
                                                    ⊢ Returning Sort: (0 + 1)
                                                  ⊢ Checking declaration's body has expected type
                                                  ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                    ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.basicDef  : Sort((0 + 1)) := Sort(0) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.arrowType  : Sort((0 + 1)) := (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort((0 + 1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (((0 + 1) + 1))
                                                      ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ evalM: Sort((0 + 1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: (0 + 1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), (0 + 1))) =?= VSort ((0 + 1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.arrowType  : Sort((0 + 1)) := (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.dependentType  : Sort(0) := (∀ (p : Sort(0)) , #0) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort(0)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort ((0 + 1))
                                                      ⊢ Successfully extracted Sort: (0 + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (∀ (p : Sort(0)) , #0)
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : #0
                                                        ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                      ▼ ensureSort: VSort (0)
                                                        ⊢ Successfully extracted Sort: 0
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ evalM: Sort(0)
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: 0
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), 0)) =?= VSort (0)
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.dependentType  : Sort(0) := (∀ (p : Sort(0)) , #0) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.constType  : (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))) := (λ (x : Sort((0 + 1))) => (λ (y : Sort((0 + 1))) => #1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort((0 + 1))
                                                      ▼ ensureSort: VSort (((0 + 1) + 1))
                                                        ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : Sort((0 + 1))
                                                        ▼ ensureSort: VSort (((0 + 1) + 1))
                                                          ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : Sort((0 + 1))
                                                        ▼ ensureSort: VSort (((0 + 1) + 1))
                                                          ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(((0 + 1) + 1), ((0 + 1) + 1)))
                                                        ⊢ Successfully extracted Sort: iax(((0 + 1) + 1), ((0 + 1) + 1))
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax(((0 + 1) + 1), iax(((0 + 1) + 1), ((0 + 1) + 1))))
                                                      ⊢ Successfully extracted Sort: iax(((0 + 1) + 1), iax(((0 + 1) + 1), ((0 + 1) + 1)))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (x : Sort((0 + 1))) => (λ (y : Sort((0 + 1))) => #1))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort((0 + 1))
                                                      ▼ ensureSort: VSort (((0 + 1) + 1))
                                                        ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (y : Sort((0 + 1))) => #1)
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : Sort((0 + 1))
                                                        ▼ ensureSort: VSort (((0 + 1) + 1))
                                                          ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ quote @ 2 : VSort ((0 + 1))
                                                      ▼ quote @ 1 : VPi ((y : VSort ((0 + 1))) => Closure{ env: [VNeutral (x^0 [])] body: Sort((0 + 1)) })
                                                        ▼ quote @ 1 : VSort ((0 + 1))
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (y^1 []), VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ▼ quote @ 2 : VSort ((0 + 1))
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((x : VSort ((0 + 1))) => Closure{ env: [] body: (∀ (y : Sort((0 + 1))) , Sort((0 + 1))) }) =?= VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))) })
                                                      ▼ inferValue @ 0 : VPi ((x : VSort ((0 + 1))) => Closure{ env: [] body: (∀ (y : Sort((0 + 1))) , Sort((0 + 1))) })
                                                        ▼ inferValue @ 0 : VSort ((0 + 1))
                                                        ▼ evalM: (∀ (y : Sort((0 + 1))) , Sort((0 + 1)))
                                                          ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                          ⊢ Evaluating Pi doain type: y
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((y : VSort ((0 + 1))) => Closure{ env: [VNeutral (x^0 [])] body: Sort((0 + 1)) })
                                                          ▼ inferValue @ 1 : VSort ((0 + 1))
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is [VNeutral (y^1 []), VNeutral (x^0 [])]
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ▼ inferValue @ 2 : VSort ((0 + 1))
                                                      ▼ inferValue @ 0 : VSort (iax(((0 + 1) + 1), iax(((0 + 1) + 1), ((0 + 1) + 1))))
                                                      ⊢ Coparing two Pis. Checking doain types for: x
                                                      ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: (∀ (y : Sort((0 + 1))) , Sort((0 + 1)))
                                                        ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                        ⊢ Evaluating Pi doain type: y
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))
                                                        ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 1 : VPi ((y : VSort ((0 + 1))) => Closure{ env: [VNeutral (x^0 [])] body: Sort((0 + 1)) }) =?= VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [VNeutral (x^0 [])] body: Sort((0 + 1)) })
                                                        ▼ inferValue @ 1 : VPi ((y : VSort ((0 + 1))) => Closure{ env: [VNeutral (x^0 [])] body: Sort((0 + 1)) })
                                                          ▼ inferValue @ 1 : VSort ((0 + 1))
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is [VNeutral (y^1 []), VNeutral (x^0 [])]
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ▼ inferValue @ 2 : VSort ((0 + 1))
                                                        ▼ inferValue @ 1 : VSort (iax(((0 + 1) + 1), ((0 + 1) + 1)))
                                                        ⊢ Coparing two Pis. Checking doain types for: y
                                                        ▼ isDefEqValue @ 1 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                          ⊢ Matched via level equivalence
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (y^1 []), VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (y^1 []), VNeutral (x^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ▼ isDefEqValue @ 2 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                          ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.constType  : (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))) := (λ (x : Sort((0 + 1))) => (λ (y : Sort((0 + 1))) => #1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.betaReduction  : ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) := (∀ (p : Sort(0)) , #0) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))
                                                      ⊢ Inferring function type
                                                      ▼ inferExpr @ 0 : (TutorialFixture.constType Sort(0))
                                                        ⊢ Inferring function type
                                                        ▼ inferExpr @ 0 : TutorialFixture.constType
                                                          ⊢ Looking up Const type: TutorialFixture.constType
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort((0 + 1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: (0 + 1)
                                                            ⊢ Building closure for Pi body with environent
                                                        ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))) })
                                                          ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                        ⊢ Evaluating arguent and inferring its type
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ⊢ Checking arguent type against doain type
                                                        ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                          ⊢ Matched via level equivalence
                                                        ⊢ Type check passed. Instantiating codoain.
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))
                                                          ⊢ LocalEnv is [VSort (0)]
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is [VSort (0)]
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ⊢ Building closure for Pi body with environent
                                                      ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [VSort (0)] body: Sort((0 + 1)) })
                                                        ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                      ⊢ Evaluating arguent and inferring its type
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 1 : VSort (0)
                                                      ⊢ Checking arguent type against doain type
                                                      ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), (0 + 1))) =?= VSort ((0 + 1))
                                                        ⊢ Matched via level equivalence
                                                      ⊢ Type check passed. Instantiating codoain.
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is [VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) }), VSort (0)]
                                                        ⊢ Returning Sort: (0 + 1)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort ((0 + 1))
                                                      ⊢ Successfully extracted Sort: (0 + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (∀ (p : Sort(0)) , #0)
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : #0
                                                        ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                      ▼ ensureSort: VSort (0)
                                                        ⊢ Successfully extracted Sort: 0
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ evalM: ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating App function
                                                      ▼ evalM: (TutorialFixture.constType Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: TutorialFixture.constType
                                                          ⊢ LocalEnv is []
                                                          ⊢ Looking up Const: TutorialFixture.constType
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 0 : VDef (TutorialFixture.constType [] [] <thunk>) ∘ EApp (VSort (0))
                                                          ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.constType
                                                      ⊢ Evaluating App arguent
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Applying arguent to function
                                                      ▼ applyEliM @ 0 : VDef (TutorialFixture.constType [] [EApp (VSort (0))] <thunk>) ∘ EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) }))
                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.constType
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), 0)) =?= VDef (TutorialFixture.constType [] [EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })), EApp (VSort (0))] <thunk>)
                                                      ▼ inferValue @ 0 : VSort (iax((0 + 1), 0))
                                                      ▼ inferValue @ 0 : VSort ((iax((0 + 1), 0) + 1))
                                                      ▼ evalM: (λ (x : Sort((0 + 1))) => (λ (y : Sort((0 + 1))) => #1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating La doain type x
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Building closure for La body with environent
                                                      ▼ applyEliM @ 0 : VLa ((x : VSort ((0 + 1))) => Closure{ env: [] body: (λ (y : Sort((0 + 1))) => #1) }) ∘ EApp (VSort (0))
                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                        ▼ evalM: (λ (y : Sort((0 + 1))) => #1)
                                                          ⊢ LocalEnv is [VSort (0)]
                                                          ⊢ Evaluating La doain type y
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is [VSort (0)]
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ⊢ Building closure for La body with environent
                                                      ▼ applyEliM @ 0 : VLa ((y : VSort ((0 + 1))) => Closure{ env: [VSort (0)] body: #1 }) ∘ EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) }))
                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) }), VSort (0)]
                                                          ⊢ Looking up bound variable
                                                      ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), 0)) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.betaReduction  : ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) := (∀ (p : Sort(0)) , #0) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.betaReduction2  : (∀ (p : Sort(0)) , ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))) := (λ (p : Sort(0)) => #0) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (p : Sort(0)) , ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))
                                                        ⊢ Inferring function type
                                                        ▼ inferExpr @ 1 : (TutorialFixture.constType Sort(0))
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 1 : TutorialFixture.constType
                                                            ⊢ Looking up Const type: TutorialFixture.constType
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: Sort((0 + 1))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: (0 + 1)
                                                              ⊢ Building closure for Pi body with environent
                                                          ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1))) })
                                                            ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ inferValue @ 1 : VSort (0)
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 1 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                            ⊢ Matched via level equivalence
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort((0 + 1))) , Sort((0 + 1)))
                                                            ⊢ LocalEnv is [VSort (0)]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort((0 + 1))
                                                              ⊢ LocalEnv is [VSort (0)]
                                                              ⊢ Returning Sort: (0 + 1)
                                                            ⊢ Building closure for Pi body with environent
                                                        ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VSort ((0 + 1))) => Closure{ env: [VSort (0)] body: Sort((0 + 1)) })
                                                          ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                        ⊢ Evaluating arguent and inferring its type
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) })
                                                          ▼ inferValue @ 1 : VSort (0)
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (p^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ inferValue @ 2 : VSort (0)
                                                        ⊢ Checking arguent type against doain type
                                                        ▼ isDefEqValue @ 1 : VSort (iax((0 + 1), (0 + 1))) =?= VSort ((0 + 1))
                                                          ⊢ Matched via level equivalence
                                                        ⊢ Type check passed. Instantiating codoain.
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) }), VSort (0)]
                                                          ⊢ Returning Sort: (0 + 1)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                      ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (p : Sort(0)) => #0)
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : #0
                                                        ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                      ▼ quote @ 1 : VSort (0)
                                                    ▼ evalM: (∀ (p : Sort(0)) , ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: p
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((p : VSort (0)) => Closure{ env: [] body: Sort(0) }) =?= VPi ((p : VSort (0)) => Closure{ env: [] body: ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) })
                                                      ▼ inferValue @ 0 : VPi ((p : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 1 : VSort (0)
                                                      ▼ inferValue @ 0 : VSort (iax((0 + 1), (0 + 1)))
                                                      ⊢ Coparing two Pis. Checking doain types for: p
                                                      ▼ isDefEqValue @ 0 : VSort (0) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                        ⊢ Returning Sort: 0
                                                      ▼ evalM: ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))
                                                        ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: (TutorialFixture.constType Sort(0))
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: TutorialFixture.constType
                                                            ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                            ⊢ Looking up Const: TutorialFixture.constType
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 1 : VDef (TutorialFixture.constType [] [] <thunk>) ∘ EApp (VSort (0))
                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.constType
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 1 : VDef (TutorialFixture.constType [] [EApp (VSort (0))] <thunk>) ∘ EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) }))
                                                          ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.constType
                                                      ▼ isDefEqValue @ 1 : VSort (0) =?= VDef (TutorialFixture.constType [] [EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) })), EApp (VSort (0))] <thunk>)
                                                        ▼ inferValue @ 1 : VSort (0)
                                                        ▼ inferValue @ 1 : VSort ((0 + 1))
                                                        ▼ evalM: (λ (x : Sort((0 + 1))) => (λ (y : Sort((0 + 1))) => #1))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating La doain type x
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ⊢ Building closure for La body with environent
                                                        ▼ applyEliM @ 1 : VLa ((x : VSort ((0 + 1))) => Closure{ env: [] body: (λ (y : Sort((0 + 1))) => #1) }) ∘ EApp (VSort (0))
                                                          ⊢ Beta Reduction: evaluating body with new environent
                                                          ▼ evalM: (λ (y : Sort((0 + 1))) => #1)
                                                            ⊢ LocalEnv is [VSort (0)]
                                                            ⊢ Evaluating La doain type y
                                                            ▼ evalM: Sort((0 + 1))
                                                              ⊢ LocalEnv is [VSort (0)]
                                                              ⊢ Returning Sort: (0 + 1)
                                                            ⊢ Building closure for La body with environent
                                                        ▼ applyEliM @ 1 : VLa ((y : VSort ((0 + 1))) => Closure{ env: [VSort (0)] body: #1 }) ∘ EApp (VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) }))
                                                          ⊢ Beta Reduction: evaluating body with new environent
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (p^0 [])] body: Sort(0) }), VSort (0)]
                                                            ⊢ Looking up bound variable
                                                        ▼ isDefEqValue @ 1 : VSort (0) =?= VSort (0)
                                                          ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.betaReduction2  : (∀ (p : Sort(0)) , ((TutorialFixture.constType Sort(0)) (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)))) := (λ (p : Sort(0)) => #0) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.id [u] : (∀ {α : Sort(u)} , (∀ (a : #0) , #1)) := (λ {α : Sort(u)} => (λ (a : #0) => #0)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ {α : Sort(u)} , (∀ (a : #0) , #1))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(u)
                                                      ▼ ensureSort: VSort ((u + 1))
                                                        ⊢ Successfully extracted Sort: (u + 1)
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a : #0) , #1)
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (u)
                                                          ⊢ Successfully extracted Sort: u
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (u)
                                                          ⊢ Successfully extracted Sort: u
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(u, u))
                                                        ⊢ Successfully extracted Sort: iax(u, u)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u + 1), iax(u, u)))
                                                      ⊢ Successfully extracted Sort: iax((u + 1), iax(u, u))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ {α : Sort(u)} => (λ (a : #0) => #0))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(u)
                                                      ▼ ensureSort: VSort ((u + 1))
                                                        ⊢ Successfully extracted Sort: (u + 1)
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (a : #0) => #0)
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (u)
                                                          ⊢ Successfully extracted Sort: u
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 1
                                                        ▼ quote @ 2 : VNeutral (α^0 [])
                                                          ⊢ Constructed head expression: α^0
                                                      ▼ quote @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                        ▼ quote @ 1 : VNeutral (α^0 [])
                                                          ⊢ Constructed head expression: α^0
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ quote @ 2 : VNeutral (α^0 [])
                                                          ⊢ Constructed head expression: α^0
                                                    ▼ evalM: (∀ {α : Sort(u)} , (∀ (a : #0) , #1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: α
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ({α : VSort (u)} => Closure{ env: [] body: (∀ (a : #0) , #1) }) =?= VPi ({α : VSort (u)} => Closure{ env: [] body: (∀ (a : #0) , #1) })
                                                      ▼ inferValue @ 0 : VPi ({α : VSort (u)} => Closure{ env: [] body: (∀ (a : #0) , #1) })
                                                        ▼ inferValue @ 0 : VSort (u)
                                                        ▼ evalM: (∀ (a : #0) , #1)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                          ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((u + 1), iax(u, u)))
                                                      ⊢ Coparing two Pis. Checking doain types for: α
                                                      ▼ isDefEqValue @ 0 : VSort (u) =?= VSort (u)
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: (∀ (a : #0) , #1)
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Evaluating Pi doain type: a
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: (∀ (a : #0) , #1)
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Evaluating Pi doain type: a
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 }) =?= VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                        ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                          ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 1 : VSort (iax(u, u))
                                                        ⊢ Coparing two Pis. Checking doain types for: a
                                                        ▼ isDefEqValue @ 1 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                          ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (u)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 1 : [] =?= []
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ isDefEqValue @ 2 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                          ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                            ▼ inferHeadApp: α^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (u)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 2 : [] =?= []
                                                  ⊢ Inserting declaration: def TutorialFixture.id [u] : (∀ {α : Sort(u)} , (∀ (a : #0) , #1)) := (λ {α : Sort(u)} => (λ (a : #0) => #0)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.forallSortWhnf  : Sort(0) := (∀ (p : ((TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1))) Sort(0))) , (∀ (a : #0) , #1)) [regular 2]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort(0)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort ((0 + 1))
                                                      ⊢ Successfully extracted Sort: (0 + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (∀ (p : ((TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1))) Sort(0))) , (∀ (a : #0) , #1))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : ((TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1))) Sort(0))
                                                        ⊢ Inferring function type
                                                        ▼ inferExpr @ 0 : (TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1)))
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 0 : TutorialFixture.id[((0 + 1) + 1)]
                                                            ⊢ Looking up Const type: TutorialFixture.id
                                                            ▼ evalM: (∀ {α : Sort(((0 + 1) + 1))} , (∀ (a : #0) , #1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating Pi doain type: α
                                                              ▼ evalM: Sort(((0 + 1) + 1))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: ((0 + 1) + 1)
                                                              ⊢ Building closure for Pi body with environent
                                                          ▼ ensurePi: VPi ({α : VSort (((0 + 1) + 1))} => Closure{ env: [] body: (∀ (a : #0) , #1) })
                                                            ⊢ Successfully extracted Pi for: α
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ▼ inferValue @ 0 : VSort ((0 + 1))
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 0 : VSort (((0 + 1) + 1)) =?= VSort (((0 + 1) + 1))
                                                            ⊢ Matched via level equivalence
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VSort ((0 + 1))]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VSort ((0 + 1))]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                        ▼ ensurePi: VPi ((a : VSort ((0 + 1))) => Closure{ env: [VSort ((0 + 1))] body: #1 })
                                                          ⊢ Successfully extracted Pi for: a
                                                        ⊢ Evaluating arguent and inferring its type
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ⊢ Checking arguent type against doain type
                                                        ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                          ⊢ Matched via level equivalence
                                                        ⊢ Type check passed. Instantiating codoain.
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VSort (0), VSort ((0 + 1))]
                                                          ⊢ Looking up bound variable
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: ((TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1))) Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: (TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1)))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: TutorialFixture.id[((0 + 1) + 1)]
                                                            ⊢ LocalEnv is []
                                                            ⊢ Looking up Const: TutorialFixture.id
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: Sort((0 + 1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: (0 + 1)
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 0 : VDef (TutorialFixture.id [((0 + 1) + 1)] [] <thunk>) ∘ EApp (VSort ((0 + 1)))
                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.id
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: 0
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 0 : VDef (TutorialFixture.id [((0 + 1) + 1)] [EApp (VSort ((0 + 1)))] <thunk>) ∘ EApp (VSort (0))
                                                          ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.id
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a : #0) , #1)
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                        ▼ force VDef: TutorialFixture.id
                                                          ▼ evalM: (λ {α : Sort(((0 + 1) + 1))} => (λ (a : #0) => #0))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Evaluating La doain type α
                                                            ▼ evalM: Sort(((0 + 1) + 1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: ((0 + 1) + 1)
                                                            ⊢ Building closure for La body with environent
                                                          ▼ applyEliM @ 0 : VLa ({α : VSort (((0 + 1) + 1))} => Closure{ env: [] body: (λ (a : #0) => #0) }) ∘ EApp (VSort ((0 + 1)))
                                                            ⊢ Beta Reduction: evaluating body with new environent
                                                            ▼ evalM: (λ (a : #0) => #0)
                                                              ⊢ LocalEnv is [VSort ((0 + 1))]
                                                              ⊢ Evaluating La doain type a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VSort ((0 + 1))]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for La body with environent
                                                          ▼ applyEliM @ 0 : VLa ((a : VSort ((0 + 1))) => Closure{ env: [VSort ((0 + 1))] body: #0 }) ∘ EApp (VSort (0))
                                                            ⊢ Beta Reduction: evaluating body with new environent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VSort (0), VSort ((0 + 1))]
                                                              ⊢ Looking up bound variable
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensureSort: VDef (TutorialFixture.id [((0 + 1) + 1)] [EApp (VSort (0)), EApp (VSort ((0 + 1)))] <thunk>)
                                                          ▼ force VDef: TutorialFixture.id
                                                            ▼ evalM: (λ {α : Sort(((0 + 1) + 1))} => (λ (a : #0) => #0))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating La doain type α
                                                              ▼ evalM: Sort(((0 + 1) + 1))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: ((0 + 1) + 1)
                                                              ⊢ Building closure for La body with environent
                                                            ▼ applyEliM @ 0 : VLa ({α : VSort (((0 + 1) + 1))} => Closure{ env: [] body: (λ (a : #0) => #0) }) ∘ EApp (VSort ((0 + 1)))
                                                              ⊢ Beta Reduction: evaluating body with new environent
                                                              ▼ evalM: (λ (a : #0) => #0)
                                                                ⊢ LocalEnv is [VSort ((0 + 1))]
                                                                ⊢ Evaluating La doain type a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VSort ((0 + 1))]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for La body with environent
                                                            ▼ applyEliM @ 0 : VLa ((a : VSort ((0 + 1))) => Closure{ env: [VSort ((0 + 1))] body: #0 }) ∘ EApp (VSort (0))
                                                              ⊢ Beta Reduction: evaluating body with new environent
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VSort (0), VSort ((0 + 1))]
                                                                ⊢ Looking up bound variable
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(0, 0))
                                                        ⊢ Successfully extracted Sort: iax(0, 0)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ evalM: Sort(0)
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: 0
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (iax((0 + 1), iax(0, 0))) =?= VSort (0)
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.forallSortWhnf  : Sort(0) := (∀ (p : ((TutorialFixture.id[((0 + 1) + 1)] Sort((0 + 1))) Sort(0))) , (∀ (a : #0) , #1)) [regular 2]
                                                  ▼ typecheckInfo: def TutorialFixture.levelCop1  : Sort((0 + 1)) := Sort(0) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort((0 + 1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (((0 + 1) + 1))
                                                      ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : Sort(0)
                                                    ▼ evalM: Sort((0 + 1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: (0 + 1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.levelCop1  : Sort((0 + 1)) := Sort(0) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.levelCop2  : Sort(((0 + 1) + 1)) := Sort((0 + 1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort(((0 + 1) + 1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort ((((0 + 1) + 1) + 1))
                                                      ⊢ Successfully extracted Sort: (((0 + 1) + 1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : Sort((0 + 1))
                                                    ▼ evalM: Sort(((0 + 1) + 1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: ((0 + 1) + 1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (((0 + 1) + 1)) =?= VSort (((0 + 1) + 1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.levelCop2  : Sort(((0 + 1) + 1)) := Sort((0 + 1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.levelCop3  : Sort((((0 + 1) + 1) + 1)) := Sort(((0 + 1) + 1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort((((0 + 1) + 1) + 1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (((((0 + 1) + 1) + 1) + 1))
                                                      ⊢ Successfully extracted Sort: ((((0 + 1) + 1) + 1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : Sort(((0 + 1) + 1))
                                                    ▼ evalM: Sort((((0 + 1) + 1) + 1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: (((0 + 1) + 1) + 1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort ((((0 + 1) + 1) + 1)) =?= VSort ((((0 + 1) + 1) + 1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.levelCop3  : Sort((((0 + 1) + 1) + 1)) := Sort(((0 + 1) + 1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.levelParaF [u] : (∀ (a._@._internal._hyg.0 : Sort(u)) , (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u))) := (λ (α : Sort(u)) => (λ (β : Sort(u)) => #1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort(u)) , (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u)))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(u)
                                                      ▼ ensureSort: VSort ((u + 1))
                                                        ⊢ Successfully extracted Sort: (u + 1)
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : Sort(u)
                                                        ▼ ensureSort: VSort ((u + 1))
                                                          ⊢ Successfully extracted Sort: (u + 1)
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : Sort(u)
                                                        ▼ ensureSort: VSort ((u + 1))
                                                          ⊢ Successfully extracted Sort: (u + 1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax((u + 1), (u + 1)))
                                                        ⊢ Successfully extracted Sort: iax((u + 1), (u + 1))
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u + 1), iax((u + 1), (u + 1))))
                                                      ⊢ Successfully extracted Sort: iax((u + 1), iax((u + 1), (u + 1)))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (α : Sort(u)) => (λ (β : Sort(u)) => #1))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(u)
                                                      ▼ ensureSort: VSort ((u + 1))
                                                        ⊢ Successfully extracted Sort: (u + 1)
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (β : Sort(u)) => #1)
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : Sort(u)
                                                        ▼ ensureSort: VSort ((u + 1))
                                                          ⊢ Successfully extracted Sort: (u + 1)
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ quote @ 2 : VSort (u)
                                                      ▼ quote @ 1 : VPi ((β : VSort (u)) => Closure{ env: [VNeutral (α^0 [])] body: Sort(u) })
                                                        ▼ quote @ 1 : VSort (u)
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (β^1 []), VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ▼ quote @ 2 : VSort (u)
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(u)) , (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u)))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: Sort(u)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((α : VSort (u)) => Closure{ env: [] body: (∀ (β : Sort(u)) , Sort(u)) }) =?= VPi ((a._@._internal._hyg.0 : VSort (u)) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u)) })
                                                      ▼ inferValue @ 0 : VPi ((α : VSort (u)) => Closure{ env: [] body: (∀ (β : Sort(u)) , Sort(u)) })
                                                        ▼ inferValue @ 0 : VSort (u)
                                                        ▼ evalM: (∀ (β : Sort(u)) , Sort(u))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: β
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((β : VSort (u)) => Closure{ env: [VNeutral (α^0 [])] body: Sort(u) })
                                                          ▼ inferValue @ 1 : VSort (u)
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (β^1 []), VNeutral (α^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ▼ inferValue @ 2 : VSort (u)
                                                      ▼ inferValue @ 0 : VSort (iax((u + 1), iax((u + 1), (u + 1))))
                                                      ⊢ Coparing two Pis. Checking doain types for: α
                                                      ▼ isDefEqValue @ 0 : VSort (u) =?= VSort (u)
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: (∀ (β : Sort(u)) , Sort(u))
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Evaluating Pi doain type: β
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u))
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 1 : VPi ((β : VSort (u)) => Closure{ env: [VNeutral (α^0 [])] body: Sort(u) }) =?= VPi ((a._@._internal._hyg.0 : VSort (u)) => Closure{ env: [VNeutral (α^0 [])] body: Sort(u) })
                                                        ▼ inferValue @ 1 : VPi ((β : VSort (u)) => Closure{ env: [VNeutral (α^0 [])] body: Sort(u) })
                                                          ▼ inferValue @ 1 : VSort (u)
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (β^1 []), VNeutral (α^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ▼ inferValue @ 2 : VSort (u)
                                                        ▼ inferValue @ 1 : VSort (iax((u + 1), (u + 1)))
                                                        ⊢ Coparing two Pis. Checking doain types for: β
                                                        ▼ isDefEqValue @ 1 : VSort (u) =?= VSort (u)
                                                          ⊢ Matched via level equivalence
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (β^1 []), VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ▼ evalM: Sort(u)
                                                          ⊢ LocalEnv is [VNeutral (β^1 []), VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: u
                                                        ▼ isDefEqValue @ 2 : VSort (u) =?= VSort (u)
                                                          ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.levelParaF [u] : (∀ (a._@._internal._hyg.0 : Sort(u)) , (∀ (a._@._internal._hyg.0 : Sort(u)) , Sort(u))) := (λ (α : Sort(u)) => (λ (β : Sort(u)) => #1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.levelCop5 [u] : Sort((u + 1)) := Sort(u) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort((u + 1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (((u + 1) + 1))
                                                      ⊢ Successfully extracted Sort: ((u + 1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : Sort(u)
                                                    ▼ evalM: Sort((u + 1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: (u + 1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort ((u + 1)) =?= VSort ((u + 1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.levelCop5 [u] : Sort((u + 1)) := Sort(u) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.iax1  : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)) := (λ (p : Sort(0)) => (∀ (a : Sort((0 + 1))) , #1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                      ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (p : Sort(0)) => (∀ (a : Sort((0 + 1))) , #1))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a : Sort((0 + 1))) , #1)
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : Sort((0 + 1))
                                                        ▼ ensureSort: VSort (((0 + 1) + 1))
                                                          ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ quote @ 1 : VSort (iax(((0 + 1) + 1), 0))
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((p : VSort (0)) => Closure{ env: [] body: Sort(iax(((0 + 1) + 1), 0)) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                      ▼ inferValue @ 0 : VPi ((p : VSort (0)) => Closure{ env: [] body: Sort(iax(((0 + 1) + 1), 0)) })
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ▼ evalM: Sort(iax(((0 + 1) + 1), 0))
                                                          ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                          ⊢ Returning Sort: iax(((0 + 1) + 1), 0)
                                                        ▼ inferValue @ 1 : VSort (iax(((0 + 1) + 1), 0))
                                                      ▼ inferValue @ 0 : VSort (iax((0 + 1), (iax(((0 + 1) + 1), 0) + 1)))
                                                      ⊢ Coparing two Pis. Checking doain types for: p
                                                      ▼ isDefEqValue @ 0 : VSort (0) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: Sort(iax(((0 + 1) + 1), 0))
                                                        ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                        ⊢ Returning Sort: iax(((0 + 1) + 1), 0)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is [VNeutral (p^0 [])]
                                                        ⊢ Returning Sort: 0
                                                      ▼ isDefEqValue @ 1 : VSort (iax(((0 + 1) + 1), 0)) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.iax1  : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0)) := (λ (p : Sort(0)) => (∀ (a : Sort((0 + 1))) , #1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.iax2  : (∀ (α : Sort((0 + 1))) , Sort(((0 + 1) + 1))) := (λ (α : Sort((0 + 1))) => (∀ (a : Sort((0 + 1))) , #1)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (α : Sort((0 + 1))) , Sort(((0 + 1) + 1)))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort((0 + 1))
                                                      ▼ ensureSort: VSort (((0 + 1) + 1))
                                                        ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : Sort(((0 + 1) + 1))
                                                      ▼ ensureSort: VSort ((((0 + 1) + 1) + 1))
                                                        ⊢ Successfully extracted Sort: (((0 + 1) + 1) + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax(((0 + 1) + 1), (((0 + 1) + 1) + 1)))
                                                      ⊢ Successfully extracted Sort: iax(((0 + 1) + 1), (((0 + 1) + 1) + 1))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (α : Sort((0 + 1))) => (∀ (a : Sort((0 + 1))) , #1))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort((0 + 1))
                                                      ▼ ensureSort: VSort (((0 + 1) + 1))
                                                        ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a : Sort((0 + 1))) , #1)
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : Sort((0 + 1))
                                                        ▼ ensureSort: VSort (((0 + 1) + 1))
                                                          ⊢ Successfully extracted Sort: ((0 + 1) + 1)
                                                        ▼ evalM: Sort((0 + 1))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: (0 + 1)
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensureSort: VSort ((0 + 1))
                                                          ⊢ Successfully extracted Sort: (0 + 1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ quote @ 1 : VSort (iax(((0 + 1) + 1), (0 + 1)))
                                                    ▼ evalM: (∀ (α : Sort((0 + 1))) , Sort(((0 + 1) + 1)))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: α
                                                      ▼ evalM: Sort((0 + 1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: (0 + 1)
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((α : VSort ((0 + 1))) => Closure{ env: [] body: Sort(iax(((0 + 1) + 1), (0 + 1))) }) =?= VPi ((α : VSort ((0 + 1))) => Closure{ env: [] body: Sort(((0 + 1) + 1)) })
                                                      ▼ inferValue @ 0 : VPi ((α : VSort ((0 + 1))) => Closure{ env: [] body: Sort(iax(((0 + 1) + 1), (0 + 1))) })
                                                        ▼ inferValue @ 0 : VSort ((0 + 1))
                                                        ▼ evalM: Sort(iax(((0 + 1) + 1), (0 + 1)))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Returning Sort: iax(((0 + 1) + 1), (0 + 1))
                                                        ▼ inferValue @ 1 : VSort (iax(((0 + 1) + 1), (0 + 1)))
                                                      ▼ inferValue @ 0 : VSort (iax(((0 + 1) + 1), (iax(((0 + 1) + 1), (0 + 1)) + 1)))
                                                      ⊢ Coparing two Pis. Checking doain types for: α
                                                      ▼ isDefEqValue @ 0 : VSort ((0 + 1)) =?= VSort ((0 + 1))
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: Sort(iax(((0 + 1) + 1), (0 + 1)))
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Returning Sort: iax(((0 + 1) + 1), (0 + 1))
                                                      ▼ evalM: Sort(((0 + 1) + 1))
                                                        ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                        ⊢ Returning Sort: ((0 + 1) + 1)
                                                      ▼ isDefEqValue @ 1 : VSort (iax(((0 + 1) + 1), (0 + 1))) =?= VSort (((0 + 1) + 1))
                                                        ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.iax2  : (∀ (α : Sort((0 + 1))) , Sort(((0 + 1) + 1))) := (λ (α : Sort((0 + 1))) => (∀ (a : Sort((0 + 1))) , #1)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.inferVar  : (∀ (f : Sort(0)) , (∀ (a : #0) , #1)) := (λ (f : Sort(0)) => (λ (a : #0) => #0)) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (f : Sort(0)) , (∀ (a : #0) , #1))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a : #0) , #1)
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(0, 0))
                                                        ⊢ Successfully extracted Sort: iax(0, 0)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((0 + 1), iax(0, 0)))
                                                      ⊢ Successfully extracted Sort: iax((0 + 1), iax(0, 0))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (f : Sort(0)) => (λ (a : #0) => #0))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (a : #0) => #0)
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 1
                                                        ▼ quote @ 2 : VNeutral (f^0 [])
                                                          ⊢ Constructed head expression: f^0
                                                      ▼ quote @ 1 : VPi ((a : VNeutral (f^0 [])) => Closure{ env: [VNeutral (f^0 [])] body: #1 })
                                                        ▼ quote @ 1 : VNeutral (f^0 [])
                                                          ⊢ Constructed head expression: f^0
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ quote @ 2 : VNeutral (f^0 [])
                                                          ⊢ Constructed head expression: f^0
                                                    ▼ evalM: (∀ (f : Sort(0)) , (∀ (a : #0) , #1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: f
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: 0
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((f : VSort (0)) => Closure{ env: [] body: (∀ (a : #0) , #1) }) =?= VPi ((f : VSort (0)) => Closure{ env: [] body: (∀ (a : #0) , #1) })
                                                      ▼ inferValue @ 0 : VPi ((f : VSort (0)) => Closure{ env: [] body: (∀ (a : #0) , #1) })
                                                        ▼ inferValue @ 0 : VSort (0)
                                                        ▼ evalM: (∀ (a : #0) , #1)
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((a : VNeutral (f^0 [])) => Closure{ env: [VNeutral (f^0 [])] body: #1 })
                                                          ▼ inferValue @ 1 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((0 + 1), iax(0, 0)))
                                                      ⊢ Coparing two Pis. Checking doain types for: f
                                                      ▼ isDefEqValue @ 0 : VSort (0) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                      ▼ evalM: (∀ (a : #0) , #1)
                                                        ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                        ⊢ Evaluating Pi doain type: a
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: (∀ (a : #0) , #1)
                                                        ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                        ⊢ Evaluating Pi doain type: a
                                                        ▼ evalM: #0
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 1 : VPi ((a : VNeutral (f^0 [])) => Closure{ env: [VNeutral (f^0 [])] body: #1 }) =?= VPi ((a : VNeutral (f^0 [])) => Closure{ env: [VNeutral (f^0 [])] body: #1 })
                                                        ▼ inferValue @ 1 : VPi ((a : VNeutral (f^0 [])) => Closure{ env: [VNeutral (f^0 [])] body: #1 })
                                                          ▼ inferValue @ 1 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 1 : VSort (iax(0, 0))
                                                        ⊢ Coparing two Pis. Checking doain types for: a
                                                        ▼ isDefEqValue @ 1 : VNeutral (f^0 []) =?= VNeutral (f^0 [])
                                                          ▼ inferValue @ 1 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (0)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 1 : [] =?= []
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ▼ isDefEqValue @ 2 : VNeutral (f^0 []) =?= VNeutral (f^0 [])
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (0)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 2 : [] =?= []
                                                  ⊢ Inserting declaration: def TutorialFixture.inferVar  : (∀ (f : Sort(0)) , (∀ (a : #0) , #1)) := (λ (f : Sort(0)) => (λ (a : #0) => #0)) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.defEqLabda  : (∀ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) , (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))) := (λ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) => (λ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) => (#0 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) , (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 0 : Sort(0)
                                                          ▼ ensureSort: VSort ((0 + 1))
                                                            ⊢ Successfully extracted Sort: (0 + 1)
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 1 : Sort(0)
                                                          ▼ ensureSort: VSort ((0 + 1))
                                                            ⊢ Successfully extracted Sort: (0 + 1)
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                          ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 1 : Sort(0)
                                                        ▼ ensureSort: VSort ((0 + 1))
                                                          ⊢ Successfully extracted Sort: (0 + 1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax((0 + 1), (0 + 1)), (0 + 1)))
                                                        ⊢ Successfully extracted Sort: iax(iax((0 + 1), (0 + 1)), (0 + 1))
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 1 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ Inferring Pi doain sort
                                                            ▼ inferExpr @ 1 : Sort(0)
                                                            ▼ ensureSort: VSort ((0 + 1))
                                                              ⊢ Successfully extracted Sort: (0 + 1)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                            ▼ inferExpr @ 2 : Sort(0)
                                                            ▼ ensureSort: VSort ((0 + 1))
                                                              ⊢ Successfully extracted Sort: (0 + 1)
                                                            ⊢ Calculating IMax for Pi universe level
                                                          ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                            ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 2 : (#1 #0)
                                                            ⊢ Inferring function type
                                                            ▼ inferExpr @ 2 : #1
                                                              ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                            ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                              ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                            ⊢ Evaluating arguent and inferring its type
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ inferValue @ 2 : VNeutral (a^1 [])
                                                              ▼ inferHeadApp: a^1
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                            ⊢ Checking arguent type against doain type
                                                            ▼ isDefEqValue @ 2 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                              ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                                ▼ inferValue @ 2 : VSort (0)
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (f^0 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ inferValue @ 3 : VSort (0)
                                                              ▼ inferValue @ 2 : VSort (iax((0 + 1), (0 + 1)))
                                                              ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                              ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                                ⊢ Matched via level equivalence
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ isDefEqValue @ 3 : VSort (0) =?= VSort (0)
                                                                ⊢ Matched via level equivalence
                                                            ⊢ Type check passed. Instantiating codoain.
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                              ⊢ Returning Sort: 0
                                                          ▼ ensureSort: VSort (0)
                                                            ⊢ Successfully extracted Sort: 0
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax(iax((0 + 1), (0 + 1)), 0))
                                                          ⊢ Successfully extracted Sort: iax(iax((0 + 1), (0 + 1)), 0)
                                                        ▼ evalM: (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                            ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating La doain type p
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for La body with environent
                                                          ▼ inferValue @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                              ▼ inferValue @ 3 : VNeutral (p^2 [])
                                                                ▼ inferHeadApp: p^2
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 4 : VNeutral (p^2 [])
                                                                ▼ inferHeadApp: p^2
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ quote @ 3 : VSort (iax(0, 0))
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 2 : VPi ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: Sort(iax(0, 0)) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                            ▼ inferValue @ 2 : VPi ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: Sort(iax(0, 0)) })
                                                              ▼ inferValue @ 2 : VSort (0)
                                                              ▼ evalM: Sort(iax(0, 0))
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: iax(0, 0)
                                                              ▼ inferValue @ 3 : VSort (iax(0, 0))
                                                            ▼ inferValue @ 2 : VSort (iax((0 + 1), (iax(0, 0) + 1)))
                                                            ⊢ Coparing two Pis. Checking doain types for: p
                                                            ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                            ▼ evalM: Sort(iax(0, 0))
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: iax(0, 0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (p^2 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ isDefEqValue @ 3 : VSort (iax(0, 0)) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })]
                                                            ⊢ Returning Sort: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax(iax((0 + 1), (0 + 1)), 0), 0))
                                                        ⊢ Successfully extracted Sort: iax(iax(iax((0 + 1), (0 + 1)), 0), 0)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax(iax(iax((0 + 1), (0 + 1)), (0 + 1)), iax(iax(iax((0 + 1), (0 + 1)), 0), 0)))
                                                      ⊢ Successfully extracted Sort: iax(iax(iax((0 + 1), (0 + 1)), (0 + 1)), iax(iax(iax((0 + 1), (0 + 1)), 0), 0))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) => (λ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) => (#0 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 0 : Sort(0)
                                                          ▼ ensureSort: VSort ((0 + 1))
                                                            ⊢ Successfully extracted Sort: (0 + 1)
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 1 : Sort(0)
                                                          ▼ ensureSort: VSort ((0 + 1))
                                                            ⊢ Successfully extracted Sort: (0 + 1)
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                          ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 1 : Sort(0)
                                                        ▼ ensureSort: VSort ((0 + 1))
                                                          ⊢ Successfully extracted Sort: (0 + 1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax((0 + 1), (0 + 1)), (0 + 1)))
                                                        ⊢ Successfully extracted Sort: iax(iax((0 + 1), (0 + 1)), (0 + 1))
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) => (#0 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 1 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ Inferring Pi doain sort
                                                            ▼ inferExpr @ 1 : Sort(0)
                                                            ▼ ensureSort: VSort ((0 + 1))
                                                              ⊢ Successfully extracted Sort: (0 + 1)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                            ▼ inferExpr @ 2 : Sort(0)
                                                            ▼ ensureSort: VSort ((0 + 1))
                                                              ⊢ Successfully extracted Sort: (0 + 1)
                                                            ⊢ Calculating IMax for Pi universe level
                                                          ▼ ensureSort: VSort (iax((0 + 1), (0 + 1)))
                                                            ⊢ Successfully extracted Sort: iax((0 + 1), (0 + 1))
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 2 : (#1 #0)
                                                            ⊢ Inferring function type
                                                            ▼ inferExpr @ 2 : #1
                                                              ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                            ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                              ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                            ⊢ Evaluating arguent and inferring its type
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ inferValue @ 2 : VNeutral (a^1 [])
                                                              ▼ inferHeadApp: a^1
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                            ⊢ Checking arguent type against doain type
                                                            ▼ isDefEqValue @ 2 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                              ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                                ▼ inferValue @ 2 : VSort (0)
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (f^0 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ inferValue @ 3 : VSort (0)
                                                              ▼ inferValue @ 2 : VSort (iax((0 + 1), (0 + 1)))
                                                              ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                              ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                                ⊢ Matched via level equivalence
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ isDefEqValue @ 3 : VSort (0) =?= VSort (0)
                                                                ⊢ Matched via level equivalence
                                                            ⊢ Type check passed. Instantiating codoain.
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                              ⊢ Returning Sort: 0
                                                          ▼ ensureSort: VSort (0)
                                                            ⊢ Successfully extracted Sort: 0
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax(iax((0 + 1), (0 + 1)), 0))
                                                          ⊢ Successfully extracted Sort: iax(iax((0 + 1), (0 + 1)), 0)
                                                        ▼ evalM: (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (#0 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 2 : #0
                                                            ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 1
                                                          ▼ ensurePi: VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                            ⊢ Successfully extracted Pi for: a
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating La doain type p
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for La body with environent
                                                          ▼ inferValue @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                              ▼ inferValue @ 3 : VNeutral (p^2 [])
                                                                ▼ inferHeadApp: p^2
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 4 : VNeutral (p^2 [])
                                                                ▼ inferHeadApp: p^2
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ quote @ 3 : VSort (iax(0, 0))
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 2 : VPi ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: Sort(iax(0, 0)) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                            ▼ inferValue @ 2 : VPi ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: Sort(iax(0, 0)) })
                                                              ▼ inferValue @ 2 : VSort (0)
                                                              ▼ evalM: Sort(iax(0, 0))
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: iax(0, 0)
                                                              ▼ inferValue @ 3 : VSort (iax(0, 0))
                                                            ▼ inferValue @ 2 : VSort (iax((0 + 1), (iax(0, 0) + 1)))
                                                            ⊢ Coparing two Pis. Checking doain types for: p
                                                            ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                            ▼ evalM: Sort(iax(0, 0))
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: iax(0, 0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ isDefEqValue @ 3 : VSort (iax(0, 0)) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ⊢ Appending eli to neutral spine
                                                        ▼ quote @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                          ⊢ Constructed head expression: f^0
                                                          ▼ quote @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                            ▼ quote @ 2 : VSort (0)
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ quote @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                              ▼ quote @ 3 : VNeutral (p^2 [])
                                                                ⊢ Constructed head expression: p^2
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 4 : VNeutral (p^2 [])
                                                                ⊢ Constructed head expression: p^2
                                                      ▼ quote @ 1 : VPi ((g : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))) })
                                                        ▼ quote @ 1 : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                          ▼ quote @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                            ▼ quote @ 1 : VSort (0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ quote @ 2 : VSort (0)
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ quote @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                            ⊢ Constructed head expression: f^0
                                                            ▼ quote @ 2 : VNeutral (a^1 [])
                                                              ⊢ Constructed head expression: a^1
                                                        ▼ evalM: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                          ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating La doain type p
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for La body with environent
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ quote @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                          ⊢ Constructed head expression: f^0
                                                          ▼ quote @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                            ▼ quote @ 2 : VSort (0)
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ quote @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                              ▼ quote @ 3 : VNeutral (p^2 [])
                                                                ⊢ Constructed head expression: p^2
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 4 : VNeutral (p^2 [])
                                                                ⊢ Constructed head expression: p^2
                                                    ▼ evalM: (∀ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) , (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: f
                                                      ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: 0
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((f : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))) }) =?= VPi ((f : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))) })
                                                      ▼ inferValue @ 0 : VPi ((f : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))) })
                                                        ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                          ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                            ▼ inferValue @ 0 : VSort (0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ inferValue @ 1 : VSort (0)
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ inferValue @ 1 : VSort (0)
                                                        ▼ evalM: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: g
                                                          ▼ evalM: (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((g : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))) })
                                                          ▼ inferValue @ 1 : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                            ▼ inferValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                              ▼ inferValue @ 1 : VSort (0)
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ inferValue @ 2 : VSort (0)
                                                            ▼ evalM: (#1 #0)
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating App function
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Evaluating App arguent
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Applying arguent to function
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                            ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                              ▼ inferHeadApp: f^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (a^1 []))
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                  ⊢ Appending eli to neutral spine
                                                                ⊢ Successfully applied spine.
                                                          ▼ evalM: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating La doain type p
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ⊢ Building closure for La body with environent
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax(iax(iax((0 + 1), (0 + 1)), (0 + 1)), iax(iax(iax((0 + 1), (0 + 1)), 0), 0)))
                                                      ⊢ Coparing two Pis. Checking doain types for: f
                                                      ▼ isDefEqValue @ 0 : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                        ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) })
                                                          ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                            ▼ inferValue @ 0 : VSort (0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ inferValue @ 1 : VSort (0)
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ inferValue @ 1 : VSort (0)
                                                        ▼ inferValue @ 0 : VSort (iax(iax((0 + 1), (0 + 1)), (0 + 1)))
                                                        ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                        ▼ isDefEqValue @ 0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                          ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })
                                                            ▼ inferValue @ 0 : VSort (0)
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ inferValue @ 1 : VSort (0)
                                                          ▼ inferValue @ 0 : VSort (iax((0 + 1), (0 + 1)))
                                                          ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                          ▼ isDefEqValue @ 0 : VSort (0) =?= VSort (0)
                                                            ⊢ Matched via level equivalence
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                            ⊢ Returning Sort: 0
                                                          ▼ isDefEqValue @ 1 : VSort (0) =?= VSort (0)
                                                            ⊢ Matched via level equivalence
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ isDefEqValue @ 1 : VSort (0) =?= VSort (0)
                                                          ⊢ Matched via level equivalence
                                                      ▼ evalM: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))
                                                        ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                        ⊢ Evaluating Pi doain type: g
                                                        ▼ evalM: (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))
                                                        ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                        ⊢ Evaluating Pi doain type: g
                                                        ▼ evalM: (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))
                                                          ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))
                                                            ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 1 : VPi ((g : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))) }) =?= VPi ((g : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))) })
                                                        ▼ inferValue @ 1 : VPi ((g : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))) })
                                                          ▼ inferValue @ 1 : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                            ▼ inferValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                              ▼ inferValue @ 1 : VSort (0)
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ inferValue @ 2 : VSort (0)
                                                            ▼ evalM: (#1 #0)
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating App function
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Evaluating App arguent
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Applying arguent to function
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                            ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                              ▼ inferHeadApp: f^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (a^1 []))
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                  ⊢ Appending eli to neutral spine
                                                                ⊢ Successfully applied spine.
                                                          ▼ evalM: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating La doain type p
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ⊢ Building closure for La body with environent
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 1 : VSort (iax(iax(iax((0 + 1), (0 + 1)), 0), 0))
                                                        ⊢ Coparing two Pis. Checking doain types for: g
                                                        ▼ isDefEqValue @ 1 : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) }) =?= VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                          ▼ inferValue @ 1 : VPi ((a : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })) => Closure{ env: [VNeutral (f^0 [])] body: (#1 #0) })
                                                            ▼ inferValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                              ▼ inferValue @ 1 : VSort (0)
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ inferValue @ 2 : VSort (0)
                                                            ▼ evalM: (#1 #0)
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Evaluating App function
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Evaluating App arguent
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Applying arguent to function
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                            ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                              ▼ inferHeadApp: f^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (a^1 []))
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                  ⊢ Appending eli to neutral spine
                                                                ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (iax(iax((0 + 1), (0 + 1)), 0))
                                                          ⊢ Coparing two Pis. Checking doain types for: a
                                                          ▼ isDefEqValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                            ▼ inferValue @ 1 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                              ▼ inferValue @ 1 : VSort (0)
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ inferValue @ 2 : VSort (0)
                                                            ▼ inferValue @ 1 : VSort (iax((0 + 1), (0 + 1)))
                                                            ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                            ▼ isDefEqValue @ 1 : VSort (0) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                              ⊢ Matched via level equivalence
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (f^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ isDefEqValue @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))]) =?= VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                            ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VNeutral (a^1 []))])
                                                              ▼ inferHeadApp: f^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (a^1 []))
                                                                ▼ evalM: Sort(0)
                                                                  ⊢ LocalEnv is [VNeutral (a^1 [])]
                                                                  ⊢ Returning Sort: 0
                                                                ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VNeutral (a^1 []))
                                                                  ⊢ Appending eli to neutral spine
                                                                ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 2 : VSort (0)
                                                            ⊢ Coparing spines with because heads atch.
                                                            ▼ isDefEqSpine @ 2 : [EApp (VNeutral (a^1 []))] =?= [EApp (VNeutral (a^1 []))]
                                                              ▼ isDefEqValue @ 2 : VNeutral (a^1 []) =?= VNeutral (a^1 [])
                                                                ▼ inferValue @ 2 : VNeutral (a^1 [])
                                                                  ▼ inferHeadApp: a^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [VNeutral (f^0 [])] body: Sort(0) })
                                                                  ▼ inferValue @ 2 : VSort (0)
                                                                  ▼ evalM: Sort(0)
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (f^0 [])]
                                                                    ⊢ Returning Sort: 0
                                                                  ▼ inferValue @ 3 : VSort (0)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 2 : [] =?= []
                                                        ▼ evalM: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                          ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating La doain type p
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for La body with environent
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ evalM: (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1)))
                                                          ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: (λ (p : Sort(0)) => (∀ (a : #0) , #1))
                                                            ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                            ⊢ Evaluating La doain type p
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VNeutral (g^1 []), VNeutral (f^0 [])]
                                                              ⊢ Returning Sort: 0
                                                            ⊢ Building closure for La body with environent
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ isDefEqValue @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))]) =?= VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                          ▼ inferValue @ 2 : VNeutral (f^0 [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))])
                                                            ▼ inferHeadApp: f^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a._@._internal._hyg.0 : VSort (0)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (f^0 []) ∘ EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (0)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 2 : [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))] =?= [EApp (VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }))]
                                                            ▼ isDefEqValue @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) }) =?= VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                              ▼ inferValue @ 2 : VLa ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: (∀ (a : #0) , #1) })
                                                                ▼ evalM: (∀ (a : #0) , #1)
                                                                  ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                                  ▼ inferValue @ 3 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ quote @ 3 : VSort (iax(0, 0))
                                                              ▼ inferValue @ 2 : VPi ((p : VSort (0)) => Closure{ env: [VNeutral (g^1 []), VNeutral (f^0 [])] body: Sort(iax(0, 0)) })
                                                                ▼ inferValue @ 2 : VSort (0)
                                                                ▼ evalM: Sort(iax(0, 0))
                                                                  ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Returning Sort: iax(0, 0)
                                                                ▼ inferValue @ 3 : VSort (iax(0, 0))
                                                              ⊢ Coparing two labdas. Checking doain types for: p
                                                              ▼ isDefEqValue @ 2 : VSort (0) =?= VSort (0)
                                                                ⊢ Matched via level equivalence
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ isDefEqValue @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 }) =?= VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                                ▼ inferValue @ 3 : VPi ((a : VNeutral (p^2 [])) => Closure{ env: [VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])] body: #1 })
                                                                  ▼ inferValue @ 3 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 3 : VSort (iax(0, 0))
                                                                ⊢ Coparing two Pis. Checking doain types for: a
                                                                ▼ isDefEqValue @ 3 : VNeutral (p^2 []) =?= VNeutral (p^2 [])
                                                                  ▼ inferValue @ 3 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 3 : VSort (0)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 3 : [] =?= []
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (p^2 []), VNeutral (g^1 []), VNeutral (f^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ isDefEqValue @ 4 : VNeutral (p^2 []) =?= VNeutral (p^2 [])
                                                                  ▼ inferValue @ 4 : VNeutral (p^2 [])
                                                                    ▼ inferHeadApp: p^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 4 : VSort (0)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 4 : [] =?= []
                                                  ⊢ Inserting declaration: def TutorialFixture.defEqLabda  : (∀ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) , (∀ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) , (#1 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))) := (λ (f : (∀ (a._@._internal._hyg.0 : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , Sort(0))) => (λ (g : (∀ (a : (∀ (a._@._internal._hyg.0 : Sort(0)) , Sort(0))) , (#1 #0))) => (#0 (λ (p : Sort(0)) => (∀ (a : #0) , #1))))) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.PN [u_1] : Sort(iax((u_1 + 1), u_1)) := (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : Sort(iax((u_1 + 1), u_1))
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort ((iax((u_1 + 1), u_1) + 1))
                                                      ⊢ Successfully extracted Sort: (iax((u_1 + 1), u_1) + 1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : Sort(u_1)
                                                      ▼ ensureSort: VSort ((u_1 + 1))
                                                        ⊢ Successfully extracted Sort: (u_1 + 1)
                                                      ▼ evalM: Sort(u_1)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u_1
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : (∀ (a : #0) , #1)
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 1 : #0
                                                            ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax(u_1, u_1))
                                                          ⊢ Successfully extracted Sort: iax(u_1, u_1)
                                                        ▼ evalM: (∀ (a : #0) , #1)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 3 : #2
                                                            ⊢ Looking up type in local context for BVar index: 2 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax(u_1, u_1))
                                                          ⊢ Successfully extracted Sort: iax(u_1, u_1)
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax(u_1, u_1), iax(u_1, u_1)))
                                                        ⊢ Successfully extracted Sort: iax(iax(u_1, u_1), iax(u_1, u_1))
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VSort (iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1)))) =?= VSort (iax((u_1 + 1), u_1))
                                                      ⊢ Matched via level equivalence
                                                  ⊢ Inserting declaration: def TutorialFixture.PN [u_1] : Sort(iax((u_1 + 1), u_1)) := (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.PN.succ [u_1] : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1]) := (λ (n : TutorialFixture.PN[u_1]) => (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))) [regular 2]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1])
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                        ⊢ Looking up Const type: TutorialFixture.PN
                                                        ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                      ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                        ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : TutorialFixture.PN[u_1]
                                                        ⊢ Looking up Const type: TutorialFixture.PN
                                                        ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                      ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                        ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax(iax((u_1 + 1), u_1), iax((u_1 + 1), u_1)))
                                                      ⊢ Successfully extracted Sort: iax(iax((u_1 + 1), u_1), iax((u_1 + 1), u_1))
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (n : TutorialFixture.PN[u_1]) => (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                        ⊢ Looking up Const type: TutorialFixture.PN
                                                        ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                      ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                        ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : Sort(u_1)
                                                        ▼ ensureSort: VSort ((u_1 + 1))
                                                          ⊢ Successfully extracted Sort: (u_1 + 1)
                                                        ▼ evalM: Sort(u_1)
                                                          ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                          ⊢ Returning Sort: u_1
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))
                                                          ⊢ Inferring La doain type
                                                          ▼ inferExpr @ 2 : (∀ (a : #0) , #1)
                                                            ⊢ Inferring Pi doain sort
                                                            ▼ inferExpr @ 2 : #0
                                                              ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 1
                                                            ▼ ensureSort: VSort (u_1)
                                                              ⊢ Successfully extracted Sort: u_1
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                            ▼ inferExpr @ 3 : #1
                                                              ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 1
                                                            ▼ ensureSort: VSort (u_1)
                                                              ⊢ Successfully extracted Sort: u_1
                                                            ⊢ Calculating IMax for Pi universe level
                                                          ▼ ensureSort: VSort (iax(u_1, u_1))
                                                            ⊢ Successfully extracted Sort: iax(u_1, u_1)
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Inferring La body type with HLvl pushed to context
                                                          ▼ inferExpr @ 3 : (λ (z : #1) => (#1 (((#3 #2) #1) #0)))
                                                            ⊢ Inferring La doain type
                                                            ▼ inferExpr @ 3 : #1
                                                              ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 1
                                                            ▼ ensureSort: VSort (u_1)
                                                              ⊢ Successfully extracted Sort: u_1
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Inferring La body type with HLvl pushed to context
                                                            ▼ inferExpr @ 4 : (#1 (((#3 #2) #1) #0))
                                                              ⊢ Inferring function type
                                                              ▼ inferExpr @ 4 : #1
                                                                ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 2
                                                              ▼ ensurePi: VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                                ⊢ Successfully extracted Pi for: a
                                                              ⊢ Evaluating arguent and inferring its type
                                                              ▼ evalM: (((#3 #2) #1) #0)
                                                                ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Evaluating App function
                                                                ▼ evalM: ((#3 #2) #1)
                                                                  ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Evaluating App function
                                                                  ▼ evalM: (#3 #2)
                                                                    ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                    ⊢ Evaluating App function
                                                                    ▼ evalM: #3
                                                                      ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Evaluating App arguent
                                                                    ▼ evalM: #2
                                                                      ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Applying arguent to function
                                                                    ▼ applyEliM @ 4 : VNeutral (n^0 []) ∘ EApp (VNeutral (α^1 []))
                                                                      ⊢ Appending eli to neutral spine
                                                                  ⊢ Evaluating App arguent
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Applying arguent to function
                                                                  ▼ applyEliM @ 4 : VNeutral (n^0 [EApp (VNeutral (α^1 []))]) ∘ EApp (VNeutral (s^2 []))
                                                                    ⊢ Appending eli to neutral spine
                                                                ⊢ Evaluating App arguent
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Applying arguent to function
                                                                ▼ applyEliM @ 4 : VNeutral (n^0 [EApp (VNeutral (s^2 [])), EApp (VNeutral (α^1 []))]) ∘ EApp (VNeutral (z^3 []))
                                                                  ⊢ Appending eli to neutral spine
                                                              ▼ inferValue @ 4 : VNeutral (n^0 [EApp (VNeutral (z^3 [])), EApp (VNeutral (s^2 [])), EApp (VNeutral (α^1 []))])
                                                                ▼ inferHeadApp: n^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ▼ force VDef: TutorialFixture.PN
                                                                    ▼ evalM: (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                                      ⊢ LocalEnv is []
                                                                      ⊢ Evaluating Pi doain type: α
                                                                      ▼ evalM: Sort(u_1)
                                                                        ⊢ LocalEnv is []
                                                                        ⊢ Returning Sort: u_1
                                                                      ⊢ Building closure for Pi body with environent
                                                                  ⊢ applyTypeEli: VDef (TutorialFixture.PN [u_1] [] <thunk>) EApp (VNeutral (α^1 []))
                                                                  ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                                    ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                    ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                    ▼ evalM: (∀ (a : #0) , #1)
                                                                      ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                      ⊢ Evaluating Pi doain type: a
                                                                      ▼ evalM: #0
                                                                        ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ applyEliM @ 4 : VNeutral (n^0 []) ∘ EApp (VNeutral (α^1 []))
                                                                    ⊢ Appending eli to neutral spine
                                                                  ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) }) EApp (VNeutral (s^2 []))
                                                                  ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                    ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 [])]
                                                                    ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ applyEliM @ 4 : VNeutral (n^0 [EApp (VNeutral (α^1 []))]) ∘ EApp (VNeutral (s^2 []))
                                                                    ⊢ Appending eli to neutral spine
                                                                  ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 [])] body: #2 }) EApp (VNeutral (z^3 []))
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ applyEliM @ 4 : VNeutral (n^0 [EApp (VNeutral (s^2 [])), EApp (VNeutral (α^1 []))]) ∘ EApp (VNeutral (z^3 []))
                                                                    ⊢ Appending eli to neutral spine
                                                                  ⊢ Successfully applied spine.
                                                              ⊢ Checking arguent type against doain type
                                                              ▼ isDefEqValue @ 4 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 4 : VSort (u_1)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 4 : [] =?= []
                                                              ⊢ Type check passed. Instantiating codoain.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (n^0 [EApp (VNeutral (z^3 [])), EApp (VNeutral (s^2 [])), EApp (VNeutral (α^1 []))]), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                            ▼ quote @ 4 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                          ▼ quote @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                            ▼ quote @ 3 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ quote @ 4 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                        ▼ quote @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                          ▼ quote @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                            ▼ quote @ 2 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ quote @ 3 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                          ▼ evalM: (∀ (z : #1) , #2)
                                                            ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: z
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ quote @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                            ▼ quote @ 3 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ quote @ 4 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                      ▼ quote @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                        ▼ quote @ 1 : VSort (u_1)
                                                        ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                          ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                          ⊢ Evaluating Pi doain type: s
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ quote @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                          ▼ quote @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                            ▼ quote @ 2 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ quote @ 3 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                          ▼ evalM: (∀ (z : #1) , #2)
                                                            ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: z
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ quote @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                            ▼ quote @ 3 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ quote @ 4 : VNeutral (α^1 [])
                                                              ⊢ Constructed head expression: α^1
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1])
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((n : VDef (TutorialFixture.PN [u_1] [] <thunk>)) => Closure{ env: [] body: (∀ (α : Sort(u_1)) , (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))) }) =?= VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)) => Closure{ env: [] body: TutorialFixture.PN[u_1] })
                                                      ▼ inferValue @ 0 : VPi ((n : VDef (TutorialFixture.PN [u_1] [] <thunk>)) => Closure{ env: [] body: (∀ (α : Sort(u_1)) , (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))) })
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                            ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ evalM: (∀ (α : Sort(u_1)) , (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)))
                                                          ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                          ⊢ Evaluating Pi doain type: α
                                                          ▼ evalM: Sort(u_1)
                                                            ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                            ⊢ Returning Sort: u_1
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                          ▼ inferValue @ 1 : VSort (u_1)
                                                          ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ inferValue @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                            ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                              ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ evalM: (∀ (z : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                              ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax(iax((u_1 + 1), u_1), iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1)))))
                                                      ⊢ Coparing two Pis. Checking doain types for: n
                                                      ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                            ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                        ▼ isDefEqSpine @ 0 : [] =?= []
                                                        ⊢ Matched VDefs by head and spine
                                                      ▼ evalM: (∀ (α : Sort(u_1)) , (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)))
                                                        ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                        ⊢ Evaluating Pi doain type: α
                                                        ▼ evalM: Sort(u_1)
                                                          ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                          ⊢ Returning Sort: u_1
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is [VNeutral (n^0 [])]
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ▼ isDefEqValue @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) }) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferValue @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                          ▼ inferValue @ 1 : VSort (u_1)
                                                          ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ inferValue @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                            ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                              ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ evalM: (∀ (z : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                              ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                ▼ inferHeadApp: α^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 1 : VSort (iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1))))
                                                        ▼ evalM: (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: α
                                                          ▼ evalM: Sort(u_1)
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: u_1
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ isDefEqValue @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) }) =?= VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                          ▼ inferValue @ 1 : VPi ((α : VSort (u_1)) => Closure{ env: [VNeutral (n^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VSort (u_1)
                                                            ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: s
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (z : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Evaluating Pi doain type: z
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1))))
                                                          ⊢ Coparing two Pis. Checking doain types for: α
                                                          ▼ isDefEqValue @ 1 : VSort (u_1) =?= VSort (u_1)
                                                            ⊢ Matched via level equivalence
                                                          ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                            ⊢ Evaluating Pi doain type: s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ isDefEqValue @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) }) =?= VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                            ▼ inferValue @ 2 : VPi ((s : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: (∀ (z : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (z : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Evaluating Pi doain type: z
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 2 : VSort (iax(iax(u_1, u_1), iax(u_1, u_1)))
                                                            ⊢ Coparing two Pis. Checking doain types for: s
                                                            ▼ isDefEqValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 }) =?= VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (n^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 2 : VSort (iax(u_1, u_1))
                                                              ⊢ Coparing two Pis. Checking doain types for: a
                                                              ▼ isDefEqValue @ 2 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 2 : VSort (u_1)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 2 : [] =?= []
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ isDefEqValue @ 3 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 3 : VSort (u_1)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 3 : [] =?= []
                                                            ▼ evalM: (∀ (z : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                              ⊢ Evaluating Pi doain type: z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ isDefEqValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 }) =?= VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 [])] body: #2 })
                                                              ▼ inferValue @ 3 : VPi ((z : VNeutral (α^1 [])) => Closure{ env: [VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 3 : VSort (iax(u_1, u_1))
                                                              ⊢ Coparing two Pis. Checking doain types for: z
                                                              ▼ isDefEqValue @ 3 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 3 : VSort (u_1)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 3 : [] =?= []
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 []), VNeutral (n^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^3 []), VNeutral (s^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ isDefEqValue @ 4 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 4 : VSort (u_1)
                                                                ⊢ Coparing spines with because heads atch.
                                                                ▼ isDefEqSpine @ 4 : [] =?= []
                                                  ⊢ Inserting declaration: def TutorialFixture.PN.succ [u_1] : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1]) := (λ (n : TutorialFixture.PN[u_1]) => (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))) [regular 2]
                                                  ▼ typecheckInfo: def TutorialFixture.PN.zero [u_1] : TutorialFixture.PN[u_1] := (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0))) [regular 1]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                      ⊢ Looking up Const type: TutorialFixture.PN
                                                      ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                      ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0)))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 0 : Sort(u_1)
                                                      ▼ ensureSort: VSort ((u_1 + 1))
                                                        ⊢ Successfully extracted Sort: (u_1 + 1)
                                                      ▼ evalM: Sort(u_1)
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: u_1
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0))
                                                        ⊢ Inferring La doain type
                                                        ▼ inferExpr @ 1 : (∀ (a : #0) , #1)
                                                          ⊢ Inferring Pi doain sort
                                                          ▼ inferExpr @ 1 : #0
                                                            ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ⊢ Calculating IMax for Pi universe level
                                                        ▼ ensureSort: VSort (iax(u_1, u_1))
                                                          ⊢ Successfully extracted Sort: iax(u_1, u_1)
                                                        ▼ evalM: (∀ (a : #0) , #1)
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: a
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Inferring La body type with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (λ (z : #1) => #0)
                                                          ⊢ Inferring La doain type
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensureSort: VSort (u_1)
                                                            ⊢ Successfully extracted Sort: u_1
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Inferring La body type with HLvl pushed to context
                                                          ▼ inferExpr @ 3 : #0
                                                            ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 2
                                                          ▼ quote @ 3 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                        ▼ quote @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                          ▼ quote @ 2 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                          ▼ evalM: #2
                                                            ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ quote @ 3 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                      ▼ quote @ 1 : VPi ((s : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (z : #1) , #2) })
                                                        ▼ quote @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                          ▼ quote @ 1 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ quote @ 2 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                        ▼ evalM: (∀ (z : #1) , #2)
                                                          ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: z
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ quote @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                          ▼ quote @ 2 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                          ▼ evalM: #2
                                                            ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ quote @ 3 : VNeutral (α^0 [])
                                                            ⊢ Constructed head expression: α^0
                                                    ▼ evalM: TutorialFixture.PN[u_1]
                                                      ⊢ LocalEnv is []
                                                      ⊢ Looking up Const: TutorialFixture.PN
                                                      ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) }) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                      ▼ inferValue @ 0 : VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                        ▼ inferValue @ 0 : VSort (u_1)
                                                        ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: s
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ inferValue @ 1 : VPi ((s : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (z : #1) , #2) })
                                                          ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                            ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                              ▼ inferHeadApp: α^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                              ▼ inferHeadApp: α^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                          ▼ evalM: (∀ (z : #1) , #2)
                                                            ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: z
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ inferValue @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                            ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                              ▼ inferHeadApp: α^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ inferValue @ 3 : VNeutral (α^0 [])
                                                              ▼ inferHeadApp: α^0
                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1))))
                                                      ▼ evalM: (∀ (α : Sort(u_1)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Evaluating Pi doain type: α
                                                        ▼ evalM: Sort(u_1)
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: u_1
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ isDefEqValue @ 0 : VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) }) =?= VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                        ▼ inferValue @ 0 : VPi ((α : VSort (u_1)) => Closure{ env: [] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                          ▼ inferValue @ 0 : VSort (u_1)
                                                          ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ inferValue @ 1 : VPi ((s : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (z : #1) , #2) })
                                                            ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                              ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ evalM: (∀ (z : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Evaluating Pi doain type: z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 3 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 0 : VSort (iax((u_1 + 1), iax(iax(u_1, u_1), iax(u_1, u_1))))
                                                        ⊢ Coparing two Pis. Checking doain types for: α
                                                        ▼ isDefEqValue @ 0 : VSort (u_1) =?= VSort (u_1)
                                                          ⊢ Matched via level equivalence
                                                        ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: s
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                          ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                            ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: a
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ▼ isDefEqValue @ 1 : VPi ((s : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (z : #1) , #2) }) =?= VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                          ▼ inferValue @ 1 : VPi ((s : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^0 [])] body: (∀ (z : #1) , #2) })
                                                            ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                              ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ evalM: (∀ (z : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Evaluating Pi doain type: z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 3 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (iax(iax(u_1, u_1), iax(u_1, u_1)))
                                                          ⊢ Coparing two Pis. Checking doain types for: s
                                                          ▼ isDefEqValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 }) =?= VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                            ▼ inferValue @ 1 : VPi ((a : VNeutral (α^0 [])) => Closure{ env: [VNeutral (α^0 [])] body: #1 })
                                                              ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 1 : VSort (iax(u_1, u_1))
                                                            ⊢ Coparing two Pis. Checking doain types for: a
                                                            ▼ isDefEqValue @ 1 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                              ▼ inferValue @ 1 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 1 : VSort (u_1)
                                                              ⊢ Coparing spines with because heads atch.
                                                              ▼ isDefEqSpine @ 1 : [] =?= []
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (a^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ isDefEqValue @ 2 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 2 : VSort (u_1)
                                                              ⊢ Coparing spines with because heads atch.
                                                              ▼ isDefEqSpine @ 2 : [] =?= []
                                                          ▼ evalM: (∀ (z : #1) , #2)
                                                            ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: z
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                            ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ isDefEqValue @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 }) =?= VPi ((a._@._internal._hyg.0 : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                            ▼ inferValue @ 2 : VPi ((z : VNeutral (α^0 [])) => Closure{ env: [VNeutral (s^1 []), VNeutral (α^0 [])] body: #2 })
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ inferValue @ 3 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 2 : VSort (iax(u_1, u_1))
                                                            ⊢ Coparing two Pis. Checking doain types for: z
                                                            ▼ isDefEqValue @ 2 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                              ▼ inferValue @ 2 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 2 : VSort (u_1)
                                                              ⊢ Coparing spines with because heads atch.
                                                              ▼ isDefEqSpine @ 2 : [] =?= []
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ evalM: #2
                                                              ⊢ LocalEnv is [VNeutral (z^2 []), VNeutral (s^1 []), VNeutral (α^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ▼ isDefEqValue @ 3 : VNeutral (α^0 []) =?= VNeutral (α^0 [])
                                                              ▼ inferValue @ 3 : VNeutral (α^0 [])
                                                                ▼ inferHeadApp: α^0
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 3 : VSort (u_1)
                                                              ⊢ Coparing spines with because heads atch.
                                                              ▼ isDefEqSpine @ 3 : [] =?= []
                                                  ⊢ Inserting declaration: def TutorialFixture.PN.zero [u_1] : TutorialFixture.PN[u_1] := (λ (α : Sort(u_1)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0))) [regular 1]
                                                  ▼ typecheckInfo: def TutorialFixture.PN.lit0 [u_1] : TutorialFixture.PN[u_1] := TutorialFixture.PN.zero[u_1] [regular 2]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                      ⊢ Looking up Const type: TutorialFixture.PN
                                                      ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                      ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : TutorialFixture.PN.zero[u_1]
                                                      ⊢ Looking up Const type: TutorialFixture.PN.zero
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ▼ evalM: TutorialFixture.PN[u_1]
                                                      ⊢ LocalEnv is []
                                                      ⊢ Looking up Const: TutorialFixture.PN
                                                      ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                      ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                          ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                          ⊢ HConst base type successfully evaluated.
                                                          ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                      ▼ isDefEqSpine @ 0 : [] =?= []
                                                      ⊢ Matched VDefs by head and spine
                                                  ⊢ Inserting declaration: def TutorialFixture.PN.lit0 [u_1] : TutorialFixture.PN[u_1] := TutorialFixture.PN.zero[u_1] [regular 2]
                                                  ▼ typecheckInfo: def TutorialFixture.PN.lit1 [u_1] : TutorialFixture.PN[u_1] := (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit0[u_1]) [regular 3]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                      ⊢ Looking up Const type: TutorialFixture.PN
                                                      ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                      ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit0[u_1])
                                                      ⊢ Inferring function type
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN.succ[u_1]
                                                        ⊢ Looking up Const type: TutorialFixture.PN.succ
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1])
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: TutorialFixture.PN[u_1]
                                                            ⊢ LocalEnv is []
                                                            ⊢ Looking up Const: TutorialFixture.PN
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ Building closure for Pi body with environent
                                                      ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)) => Closure{ env: [] body: TutorialFixture.PN[u_1] })
                                                        ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                      ⊢ Evaluating arguent and inferring its type
                                                      ▼ evalM: TutorialFixture.PN.lit0[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN.lit0
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ▼ inferValue @ 0 : VDef (TutorialFixture.PN.lit0 [u_1] [] <thunk>)
                                                        ▼ inferHeadApp: TutorialFixture.PN.lit0[u_1]
                                                          ▼ evalM: TutorialFixture.PN[u_1]
                                                            ⊢ LocalEnv is []
                                                            ⊢ Looking up Const: TutorialFixture.PN
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ HConst base type successfully evaluated.
                                                          ⊢ Successfully applied spine.
                                                      ⊢ Checking arguent type against doain type
                                                      ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                            ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                        ▼ isDefEqSpine @ 0 : [] =?= []
                                                        ⊢ Matched VDefs by head and spine
                                                      ⊢ Type check passed. Instantiating codoain.
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit0 [u_1] [] <thunk>)]
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ▼ evalM: TutorialFixture.PN[u_1]
                                                      ⊢ LocalEnv is []
                                                      ⊢ Looking up Const: TutorialFixture.PN
                                                      ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                      ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                          ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                          ⊢ HConst base type successfully evaluated.
                                                          ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                      ▼ isDefEqSpine @ 0 : [] =?= []
                                                      ⊢ Matched VDefs by head and spine
                                                  ⊢ Inserting declaration: def TutorialFixture.PN.lit1 [u_1] : TutorialFixture.PN[u_1] := (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit0[u_1]) [regular 3]
                                                  ▼ typecheckInfo: def TutorialFixture.PN.lit2 [u_1] : TutorialFixture.PN[u_1] := (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit1[u_1]) [regular 4]
                                                    ⊢ Inferring sort of declaration's type
                                                    ▼ inferExpr @ 0 : TutorialFixture.PN[u_1]
                                                      ⊢ Looking up Const type: TutorialFixture.PN
                                                      ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                        ⊢ LocalEnv is []
                                                        ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Checking declaration's type is a valid type
                                                    ▼ ensureSort: VSort (iax((u_1 + 1), u_1))
                                                      ⊢ Successfully extracted Sort: iax((u_1 + 1), u_1)
                                                    ⊢ Inferring type of declaration's body
                                                    ▼ inferExpr @ 0 : (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit1[u_1])
                                                      ⊢ Inferring function type
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN.succ[u_1]
                                                        ⊢ Looking up Const type: TutorialFixture.PN.succ
                                                        ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u_1]) , TutorialFixture.PN[u_1])
                                                          ⊢ LocalEnv is []
                                                          ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                          ▼ evalM: TutorialFixture.PN[u_1]
                                                            ⊢ LocalEnv is []
                                                            ⊢ Looking up Const: TutorialFixture.PN
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ Building closure for Pi body with environent
                                                      ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)) => Closure{ env: [] body: TutorialFixture.PN[u_1] })
                                                        ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                      ⊢ Evaluating arguent and inferring its type
                                                      ▼ evalM: TutorialFixture.PN.lit1[u_1]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN.lit1
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ▼ inferValue @ 0 : VDef (TutorialFixture.PN.lit1 [u_1] [] <thunk>)
                                                        ▼ inferHeadApp: TutorialFixture.PN.lit1[u_1]
                                                          ▼ evalM: TutorialFixture.PN[u_1]
                                                            ⊢ LocalEnv is []
                                                            ⊢ Looking up Const: TutorialFixture.PN
                                                            ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                          ⊢ HConst base type successfully evaluated.
                                                          ⊢ Successfully applied spine.
                                                      ⊢ Checking arguent type against doain type
                                                      ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                            ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                        ▼ isDefEqSpine @ 0 : [] =?= []
                                                        ⊢ Matched VDefs by head and spine
                                                      ⊢ Type check passed. Instantiating codoain.
                                                      ▼ evalM: TutorialFixture.PN[u_1]
                                                        ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit1 [u_1] [] <thunk>)]
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ▼ evalM: TutorialFixture.PN[u_1]
                                                      ⊢ LocalEnv is []
                                                      ⊢ Looking up Const: TutorialFixture.PN
                                                      ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                    ⊢ Checking declaration's body has expected type
                                                    ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>) =?= VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                      ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u_1] [] <thunk>)
                                                        ▼ inferHeadApp: TutorialFixture.PN[u_1]
                                                          ▼ evalM: Sort(iax((u_1 + 1), u_1))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: iax((u_1 + 1), u_1)
                                                          ⊢ HConst base type successfully evaluated.
                                                          ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 0 : VSort (iax((u_1 + 1), u_1))
                                                      ▼ isDefEqSpine @ 0 : [] =?= []
                                                      ⊢ Matched VDefs by head and spine
                                                  ⊢ Inserting declaration: def TutorialFixture.PN.lit2 [u_1] : TutorialFixture.PN[u_1] := (TutorialFixture.PN.succ[u_1] TutorialFixture.PN.lit1[u_1]) [regular 4]
                                                  ⊢ Inferring sort of declaration's type
                                                  ▼ inferExpr @ 0 : (∀ (t : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))) , (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u])))
                                                    ⊢ Inferring Pi doain sort
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN[u]
                                                        ⊢ Looking up Const type: TutorialFixture.PN
                                                        ▼ evalM: Sort(iax((u + 1), u))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: iax((u + 1), u)
                                                      ▼ ensureSort: VSort (iax((u + 1), u))
                                                        ⊢ Successfully extracted Sort: iax((u + 1), u)
                                                      ▼ evalM: TutorialFixture.PN[u]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ ensureSort: VSort (iax(iax((u + 1), u), (0 + 1)))
                                                      ⊢ Successfully extracted Sort: iax(iax((u + 1), u), (0 + 1))
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: TutorialFixture.PN[u]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                    ▼ inferExpr @ 1 : (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u]))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 1 : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : TutorialFixture.PN[u]
                                                          ⊢ Looking up Const type: TutorialFixture.PN
                                                          ▼ evalM: Sort(iax((u + 1), u))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: iax((u + 1), u)
                                                        ▼ ensureSort: VSort (iax((u + 1), u))
                                                          ⊢ Successfully extracted Sort: iax((u + 1), u)
                                                        ▼ evalM: TutorialFixture.PN[u]
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (#1 #0)
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                            ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (n^1 [])
                                                            ▼ inferHeadApp: n^1
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                            ▼ inferValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                              ▼ inferHeadApp: TutorialFixture.PN[u]
                                                                ▼ evalM: Sort(iax((u + 1), u))
                                                                  ⊢ LocalEnv is []
                                                                  ⊢ Returning Sort: iax((u + 1), u)
                                                                ⊢ HConst base type successfully evaluated.
                                                                ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 2 : VSort (iax((u + 1), u))
                                                            ▼ isDefEqSpine @ 2 : [] =?= []
                                                            ⊢ Matched VDefs by head and spine
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                            ⊢ Returning Sort: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax((u + 1), u), 0))
                                                        ⊢ Successfully extracted Sort: iax(iax((u + 1), u), 0)
                                                      ▼ evalM: (∀ (n : TutorialFixture.PN[u]) , (#1 #0))
                                                        ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                        ⊢ Evaluating Pi doain type: n
                                                        ▼ evalM: TutorialFixture.PN[u]
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 2 : (#1 TutorialFixture.PN.lit2[u])
                                                        ⊢ Inferring function type
                                                        ▼ inferExpr @ 2 : #1
                                                          ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                        ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                          ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                        ⊢ Evaluating arguent and inferring its type
                                                        ▼ evalM: TutorialFixture.PN.lit2[u]
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN.lit2
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ▼ inferValue @ 2 : VDef (TutorialFixture.PN.lit2 [u] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN.lit2[u]
                                                            ▼ evalM: TutorialFixture.PN[u]
                                                              ⊢ LocalEnv is []
                                                              ⊢ Looking up Const: TutorialFixture.PN
                                                              ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ⊢ Checking arguent type against doain type
                                                        ▼ isDefEqValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                            ▼ inferHeadApp: TutorialFixture.PN[u]
                                                              ▼ evalM: Sort(iax((u + 1), u))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: iax((u + 1), u)
                                                              ⊢ HConst base type successfully evaluated.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (iax((u + 1), u))
                                                          ▼ isDefEqSpine @ 2 : [] =?= []
                                                          ⊢ Matched VDefs by head and spine
                                                        ⊢ Type check passed. Instantiating codoain.
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit2 [u] [] <thunk>)]
                                                          ⊢ Returning Sort: 0
                                                      ▼ ensureSort: VSort (0)
                                                        ⊢ Successfully extracted Sort: 0
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ ensureSort: VSort (iax(iax(iax((u + 1), u), 0), 0))
                                                      ⊢ Successfully extracted Sort: iax(iax(iax((u + 1), u), 0), 0)
                                                    ⊢ Calculating IMax for Pi universe level
                                                  ⊢ Checking declaration's type is a valid type
                                                  ▼ ensureSort: VSort (iax(iax(iax((u + 1), u), (0 + 1)), iax(iax(iax((u + 1), u), 0), 0)))
                                                    ⊢ Successfully extracted Sort: iax(iax(iax((u + 1), u), (0 + 1)), iax(iax(iax((u + 1), u), 0), 0))
                                                  ⊢ Inferring type of declaration's body
                                                  ▼ inferExpr @ 0 : (λ (t : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))) => (λ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) => (#0 TutorialFixture.PN.lit2[u])))
                                                    ⊢ Inferring La doain type
                                                    ▼ inferExpr @ 0 : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))
                                                      ⊢ Inferring Pi doain sort
                                                      ▼ inferExpr @ 0 : TutorialFixture.PN[u]
                                                        ⊢ Looking up Const type: TutorialFixture.PN
                                                        ▼ evalM: Sort(iax((u + 1), u))
                                                          ⊢ LocalEnv is []
                                                          ⊢ Returning Sort: iax((u + 1), u)
                                                      ▼ ensureSort: VSort (iax((u + 1), u))
                                                        ⊢ Successfully extracted Sort: iax((u + 1), u)
                                                      ▼ evalM: TutorialFixture.PN[u]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                      ▼ inferExpr @ 1 : Sort(0)
                                                      ▼ ensureSort: VSort ((0 + 1))
                                                        ⊢ Successfully extracted Sort: (0 + 1)
                                                      ⊢ Calculating IMax for Pi universe level
                                                    ▼ ensureSort: VSort (iax(iax((u + 1), u), (0 + 1)))
                                                      ⊢ Successfully extracted Sort: iax(iax((u + 1), u), (0 + 1))
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: TutorialFixture.PN[u]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Inferring La body type with HLvl pushed to context
                                                    ▼ inferExpr @ 1 : (λ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) => (#0 TutorialFixture.PN.lit2[u]))
                                                      ⊢ Inferring La doain type
                                                      ▼ inferExpr @ 1 : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))
                                                        ⊢ Inferring Pi doain sort
                                                        ▼ inferExpr @ 1 : TutorialFixture.PN[u]
                                                          ⊢ Looking up Const type: TutorialFixture.PN
                                                          ▼ evalM: Sort(iax((u + 1), u))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Returning Sort: iax((u + 1), u)
                                                        ▼ ensureSort: VSort (iax((u + 1), u))
                                                          ⊢ Successfully extracted Sort: iax((u + 1), u)
                                                        ▼ evalM: TutorialFixture.PN[u]
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Inferring Pi codoain sort with HLvl pushed to context
                                                        ▼ inferExpr @ 2 : (#1 #0)
                                                          ⊢ Inferring function type
                                                          ▼ inferExpr @ 2 : #1
                                                            ⊢ Looking up type in local context for BVar index: 1 which corresponds to level: 0
                                                          ▼ ensurePi: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                            ⊢ Successfully extracted Pi for: a._@._internal._hyg.0
                                                          ⊢ Evaluating arguent and inferring its type
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ▼ inferValue @ 2 : VNeutral (n^1 [])
                                                            ▼ inferHeadApp: n^1
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ Successfully applied spine.
                                                          ⊢ Checking arguent type against doain type
                                                          ▼ isDefEqValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                            ▼ inferValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                              ▼ inferHeadApp: TutorialFixture.PN[u]
                                                                ▼ evalM: Sort(iax((u + 1), u))
                                                                  ⊢ LocalEnv is []
                                                                  ⊢ Returning Sort: iax((u + 1), u)
                                                                ⊢ HConst base type successfully evaluated.
                                                                ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 2 : VSort (iax((u + 1), u))
                                                            ▼ isDefEqSpine @ 2 : [] =?= []
                                                            ⊢ Matched VDefs by head and spine
                                                          ⊢ Type check passed. Instantiating codoain.
                                                          ▼ evalM: Sort(0)
                                                            ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                            ⊢ Returning Sort: 0
                                                        ▼ ensureSort: VSort (0)
                                                          ⊢ Successfully extracted Sort: 0
                                                        ⊢ Calculating IMax for Pi universe level
                                                      ▼ ensureSort: VSort (iax(iax((u + 1), u), 0))
                                                        ⊢ Successfully extracted Sort: iax(iax((u + 1), u), 0)
                                                      ▼ evalM: (∀ (n : TutorialFixture.PN[u]) , (#1 #0))
                                                        ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                        ⊢ Evaluating Pi doain type: n
                                                        ▼ evalM: TutorialFixture.PN[u]
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Inferring La body type with HLvl pushed to context
                                                      ▼ inferExpr @ 2 : (#0 TutorialFixture.PN.lit2[u])
                                                        ⊢ Inferring function type
                                                        ▼ inferExpr @ 2 : #0
                                                          ⊢ Looking up type in local context for BVar index: 0 which corresponds to level: 1
                                                        ▼ ensurePi: VPi ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                          ⊢ Successfully extracted Pi for: n
                                                        ⊢ Evaluating arguent and inferring its type
                                                        ▼ evalM: TutorialFixture.PN.lit2[u]
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN.lit2
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ▼ inferValue @ 2 : VDef (TutorialFixture.PN.lit2 [u] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN.lit2[u]
                                                            ▼ evalM: TutorialFixture.PN[u]
                                                              ⊢ LocalEnv is []
                                                              ⊢ Looking up Const: TutorialFixture.PN
                                                              ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ⊢ Checking arguent type against doain type
                                                        ▼ isDefEqValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferValue @ 2 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                            ▼ inferHeadApp: TutorialFixture.PN[u]
                                                              ▼ evalM: Sort(iax((u + 1), u))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: iax((u + 1), u)
                                                              ⊢ HConst base type successfully evaluated.
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (iax((u + 1), u))
                                                          ▼ isDefEqSpine @ 2 : [] =?= []
                                                          ⊢ Matched VDefs by head and spine
                                                        ⊢ Type check passed. Instantiating codoain.
                                                        ▼ evalM: (#1 #0)
                                                          ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit2 [u] [] <thunk>), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit2 [u] [] <thunk>), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit2 [u] [] <thunk>), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VDef (TutorialFixture.PN.lit2 [u] [] <thunk>))
                                                            ⊢ Appending eli to neutral spine
                                                      ▼ quote @ 2 : VNeutral (t^0 [EApp (VDef (TutorialFixture.PN.lit2 [u] [] <thunk>))])
                                                        ⊢ Constructed head expression: t^0
                                                        ▼ quote @ 2 : VDef (TutorialFixture.PN.lit2 [u] [] <thunk>)
                                                          ▼ force VDef: TutorialFixture.PN.lit2
                                                            ▼ evalM: (TutorialFixture.PN.succ[u] TutorialFixture.PN.lit1[u])
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating App function
                                                              ▼ evalM: TutorialFixture.PN.succ[u]
                                                                ⊢ LocalEnv is []
                                                                ⊢ Looking up Const: TutorialFixture.PN.succ
                                                                ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                              ⊢ Evaluating App arguent
                                                              ▼ evalM: TutorialFixture.PN.lit1[u]
                                                                ⊢ LocalEnv is []
                                                                ⊢ Looking up Const: TutorialFixture.PN.lit1
                                                                ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                              ⊢ Applying arguent to function
                                                              ▼ applyEliM @ 0 : VDef (TutorialFixture.PN.succ [u] [] <thunk>) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [] <thunk>))
                                                                ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                            ▼ force VDef: TutorialFixture.PN.succ
                                                              ▼ evalM: (λ (n : TutorialFixture.PN[u]) => (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Evaluating La doain type n
                                                                ▼ evalM: TutorialFixture.PN[u]
                                                                  ⊢ LocalEnv is []
                                                                  ⊢ Looking up Const: TutorialFixture.PN
                                                                  ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                ⊢ Building closure for La body with environent
                                                              ▼ applyEliM @ 0 : VLa ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))) }) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [] <thunk>))
                                                                ⊢ Beta Reduction: evaluating body with new environent
                                                                ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))
                                                                  ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                  ⊢ Evaluating La doain type α
                                                                  ▼ evalM: Sort(u)
                                                                    ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Returning Sort: u
                                                                  ⊢ Building closure for La body with environent
                                                          ▼ quote @ 2 : VSort (u)
                                                          ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))
                                                            ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                            ⊢ Evaluating La doain type s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for La body with environent
                                                          ▼ quote @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: (λ (z : #1) => (#1 (((#3 #2) #1) #0))) })
                                                            ▼ quote @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: #1 })
                                                              ▼ quote @ 3 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 4 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                            ▼ evalM: (λ (z : #1) => (#1 (((#3 #2) #1) #0)))
                                                              ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                              ⊢ Evaluating La doain type z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for La body with environent
                                                            ▼ quote @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: (#1 (((#3 #2) #1) #0)) })
                                                              ▼ quote @ 4 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                              ▼ evalM: (#1 (((#3 #2) #1) #0))
                                                                ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                ⊢ Evaluating App function
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Evaluating App arguent
                                                                ▼ evalM: (((#3 #2) #1) #0)
                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                  ⊢ Evaluating App function
                                                                  ▼ evalM: ((#3 #2) #1)
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Evaluating App function
                                                                    ▼ evalM: (#3 #2)
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: #3
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                    ⊢ Evaluating App arguent
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Applying arguent to function
                                                                    ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                      ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                  ⊢ Evaluating App arguent
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Applying arguent to function
                                                                  ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                    ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                ⊢ Applying arguent to function
                                                                ▼ applyEliM @ 4 : VNeutral (s^3 []) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))
                                                                  ⊢ Appending eli to neutral spine
                                                              ▼ quote @ 5 : VNeutral (s^3 [EApp (VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))])
                                                                ⊢ Constructed head expression: s^3
                                                                ▼ quote @ 5 : VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>)
                                                                  ▼ force VDef: TutorialFixture.PN.lit1
                                                                    ▼ evalM: (TutorialFixture.PN.succ[u] TutorialFixture.PN.lit0[u])
                                                                      ⊢ LocalEnv is []
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: TutorialFixture.PN.succ[u]
                                                                        ⊢ LocalEnv is []
                                                                        ⊢ Looking up Const: TutorialFixture.PN.succ
                                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: TutorialFixture.PN.lit0[u]
                                                                        ⊢ LocalEnv is []
                                                                        ⊢ Looking up Const: TutorialFixture.PN.lit0
                                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 0 : VDef (TutorialFixture.PN.succ [u] [] <thunk>) ∘ EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))
                                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                    ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                      ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                    ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VNeutral (α^2 [])), EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                      ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                    ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 [])), EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                      ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                    ▼ force VDef: TutorialFixture.PN.succ
                                                                      ▼ evalM: (λ (n : TutorialFixture.PN[u]) => (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))))
                                                                        ⊢ LocalEnv is []
                                                                        ⊢ Evaluating La doain type n
                                                                        ▼ evalM: TutorialFixture.PN[u]
                                                                          ⊢ LocalEnv is []
                                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                        ⊢ Building closure for La body with environent
                                                                      ▼ applyEliM @ 0 : VLa ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))) }) ∘ EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))
                                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                                        ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))
                                                                          ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                          ⊢ Evaluating La doain type α
                                                                          ▼ evalM: Sort(u)
                                                                            ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                            ⊢ Returning Sort: u
                                                                          ⊢ Building closure for La body with environent
                                                                      ▼ applyEliM @ 4 : VLa ((α : VSort (u)) => Closure{ env: [VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))) }) ∘ EApp (VNeutral (α^2 []))
                                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                                        ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))
                                                                          ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                          ⊢ Evaluating La doain type s
                                                                          ▼ evalM: (∀ (a : #0) , #1)
                                                                            ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                            ⊢ Evaluating Pi doain type: a
                                                                            ▼ evalM: #0
                                                                              ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                              ⊢ Looking up bound variable
                                                                            ⊢ Building closure for Pi body with environent
                                                                          ⊢ Building closure for La body with environent
                                                                      ▼ applyEliM @ 4 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)] body: (λ (z : #1) => (#1 (((#3 #2) #1) #0))) }) ∘ EApp (VNeutral (s^3 []))
                                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                                        ▼ evalM: (λ (z : #1) => (#1 (((#3 #2) #1) #0)))
                                                                          ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                          ⊢ Evaluating La doain type z
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Building closure for La body with environent
                                                                      ▼ applyEliM @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)] body: (#1 (((#3 #2) #1) #0)) }) ∘ EApp (VNeutral (z^4 []))
                                                                        ⊢ Beta Reduction: evaluating body with new environent
                                                                        ▼ evalM: (#1 (((#3 #2) #1) #0))
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                          ⊢ Evaluating App function
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Evaluating App arguent
                                                                          ▼ evalM: (((#3 #2) #1) #0)
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                            ⊢ Evaluating App function
                                                                            ▼ evalM: ((#3 #2) #1)
                                                                              ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                              ⊢ Evaluating App function
                                                                              ▼ evalM: (#3 #2)
                                                                                ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                                ⊢ Evaluating App function
                                                                                ▼ evalM: #3
                                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                                  ⊢ Looking up bound variable
                                                                                ⊢ Evaluating App arguent
                                                                                ▼ evalM: #2
                                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                                  ⊢ Looking up bound variable
                                                                                ⊢ Applying arguent to function
                                                                                ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit0 [u] [] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                                  ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit0
                                                                              ⊢ Evaluating App arguent
                                                                              ▼ evalM: #1
                                                                                ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                                ⊢ Looking up bound variable
                                                                              ⊢ Applying arguent to function
                                                                              ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit0 [u] [EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                                ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit0
                                                                            ⊢ Evaluating App arguent
                                                                            ▼ evalM: #0
                                                                              ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit0 [u] [] <thunk>)]
                                                                              ⊢ Looking up bound variable
                                                                            ⊢ Applying arguent to function
                                                                            ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit0 [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                              ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit0
                                                                          ⊢ Applying arguent to function
                                                                          ▼ applyEliM @ 4 : VNeutral (s^3 []) ∘ EApp (VDef (TutorialFixture.PN.lit0 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))
                                                                            ⊢ Appending eli to neutral spine
                                                                  ⊢ Constructed head expression: s^3
                                                                  ▼ quote @ 5 : VDef (TutorialFixture.PN.lit0 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>)
                                                                    ▼ force VDef: TutorialFixture.PN.lit0
                                                                      ▼ evalM: TutorialFixture.PN.zero[u]
                                                                        ⊢ LocalEnv is []
                                                                        ⊢ Looking up Const: TutorialFixture.PN.zero
                                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                      ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.zero [u] [] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.zero
                                                                      ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.zero [u] [EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.zero
                                                                      ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.zero [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                        ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.zero
                                                                      ▼ force VDef: TutorialFixture.PN.zero
                                                                        ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0)))
                                                                          ⊢ LocalEnv is []
                                                                          ⊢ Evaluating La doain type α
                                                                          ▼ evalM: Sort(u)
                                                                            ⊢ LocalEnv is []
                                                                            ⊢ Returning Sort: u
                                                                          ⊢ Building closure for La body with environent
                                                                        ▼ applyEliM @ 4 : VLa ((α : VSort (u)) => Closure{ env: [] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0)) }) ∘ EApp (VNeutral (α^2 []))
                                                                          ⊢ Beta Reduction: evaluating body with new environent
                                                                          ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => #0))
                                                                            ⊢ LocalEnv is [VNeutral (α^2 [])]
                                                                            ⊢ Evaluating La doain type s
                                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                                              ⊢ LocalEnv is [VNeutral (α^2 [])]
                                                                              ⊢ Evaluating Pi doain type: a
                                                                              ▼ evalM: #0
                                                                                ⊢ LocalEnv is [VNeutral (α^2 [])]
                                                                                ⊢ Looking up bound variable
                                                                              ⊢ Building closure for Pi body with environent
                                                                            ⊢ Building closure for La body with environent
                                                                        ▼ applyEliM @ 4 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 [])] body: (λ (z : #1) => #0) }) ∘ EApp (VNeutral (s^3 []))
                                                                          ⊢ Beta Reduction: evaluating body with new environent
                                                                          ▼ evalM: (λ (z : #1) => #0)
                                                                            ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 [])]
                                                                            ⊢ Evaluating La doain type z
                                                                            ▼ evalM: #1
                                                                              ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 [])]
                                                                              ⊢ Looking up bound variable
                                                                            ⊢ Building closure for La body with environent
                                                                        ▼ applyEliM @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 [])] body: #0 }) ∘ EApp (VNeutral (z^4 []))
                                                                          ⊢ Beta Reduction: evaluating body with new environent
                                                                          ▼ evalM: #0
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 [])]
                                                                            ⊢ Looking up bound variable
                                                                    ⊢ Constructed head expression: z^4
                                                    ▼ quote @ 1 : VPi ((v : VPi ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))) })
                                                      ▼ quote @ 1 : VPi ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                        ▼ quote @ 1 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ force VDef: TutorialFixture.PN
                                                            ▼ evalM: (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating Pi doain type: α
                                                              ▼ evalM: Sort(u)
                                                                ⊢ LocalEnv is []
                                                                ⊢ Returning Sort: u
                                                              ⊢ Building closure for Pi body with environent
                                                          ▼ quote @ 1 : VSort (u)
                                                          ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                            ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                            ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ quote @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                            ▼ quote @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })
                                                              ▼ quote @ 2 : VNeutral (α^1 [])
                                                                ⊢ Constructed head expression: α^1
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 3 : VNeutral (α^1 [])
                                                                ⊢ Constructed head expression: α^1
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                              ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ quote @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])] body: #2 })
                                                              ▼ quote @ 3 : VNeutral (α^1 [])
                                                                ⊢ Constructed head expression: α^1
                                                              ▼ evalM: #2
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 4 : VNeutral (α^1 [])
                                                                ⊢ Constructed head expression: α^1
                                                        ▼ evalM: (#1 #0)
                                                          ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ quote @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                          ⊢ Constructed head expression: t^0
                                                          ▼ quote @ 2 : VNeutral (n^1 [])
                                                            ⊢ Constructed head expression: n^1
                                                      ▼ evalM: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))
                                                        ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating La doain type α
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ⊢ Building closure for La body with environent
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                          ⊢ Appending eli to neutral spine
                                                      ▼ quote @ 2 : VNeutral (t^0 [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))])
                                                        ⊢ Constructed head expression: t^0
                                                        ▼ quote @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })
                                                          ▼ quote @ 2 : VSort (u)
                                                          ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))
                                                            ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating La doain type s
                                                            ▼ evalM: (∀ (a : #0) , #1)
                                                              ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a
                                                              ▼ evalM: #0
                                                                ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for Pi body with environent
                                                            ⊢ Building closure for La body with environent
                                                          ▼ quote @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) })
                                                            ▼ quote @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                              ▼ quote @ 3 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ▼ quote @ 4 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                            ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                              ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating La doain type z
                                                              ▼ evalM: #1
                                                                ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Looking up bound variable
                                                              ⊢ Building closure for La body with environent
                                                            ▼ quote @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                              ▼ quote @ 4 : VNeutral (α^2 [])
                                                                ⊢ Constructed head expression: α^2
                                                              ▼ evalM: (#1 (#1 #0))
                                                                ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating App function
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Evaluating App arguent
                                                                ▼ evalM: (#1 #0)
                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating App function
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Evaluating App arguent
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Applying arguent to function
                                                                  ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                    ⊢ Appending eli to neutral spine
                                                                ⊢ Applying arguent to function
                                                                ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                  ⊢ Appending eli to neutral spine
                                                              ▼ quote @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                ⊢ Constructed head expression: s^3
                                                                ▼ quote @ 5 : VNeutral (s^3 [EApp (VNeutral (z^4 []))])
                                                                  ⊢ Constructed head expression: s^3
                                                                  ▼ quote @ 5 : VNeutral (z^4 [])
                                                                    ⊢ Constructed head expression: z^4
                                                  ▼ evalM: (∀ (t : (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))) , (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u])))
                                                    ⊢ LocalEnv is []
                                                    ⊢ Evaluating Pi doain type: t
                                                    ▼ evalM: (∀ (a._@._internal._hyg.0 : TutorialFixture.PN[u]) , Sort(0))
                                                      ⊢ LocalEnv is []
                                                      ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                      ▼ evalM: TutorialFixture.PN[u]
                                                        ⊢ LocalEnv is []
                                                        ⊢ Looking up Const: TutorialFixture.PN
                                                        ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                      ⊢ Building closure for Pi body with environent
                                                    ⊢ Building closure for Pi body with environent
                                                  ⊢ Checking declaration's body has expected type
                                                  ▼ isDefEqValue @ 0 : VPi ((t : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (v : (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))) , (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))) }) =?= VPi ((t : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u])) })
                                                    ▼ inferValue @ 0 : VPi ((t : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (v : (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))) , (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))) })
                                                      ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u]
                                                            ▼ evalM: Sort(iax((u + 1), u))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u + 1), u)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 1 : VSort (0)
                                                      ▼ evalM: (∀ (v : (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))) , (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))))
                                                        ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                        ⊢ Evaluating Pi doain type: v
                                                        ▼ evalM: (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Evaluating Pi doain type: n
                                                          ▼ evalM: (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                            ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                            ⊢ Evaluating Pi doain type: α
                                                            ▼ evalM: Sort(u)
                                                              ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                              ⊢ Returning Sort: u
                                                            ⊢ Building closure for Pi body with environent
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ▼ inferValue @ 1 : VPi ((v : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))) })
                                                        ▼ inferValue @ 1 : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                          ▼ inferValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VSort (u)
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                            ▼ inferHeadApp: t^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (n^1 []))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                        ▼ evalM: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating La doain type α
                                                            ▼ evalM: Sort(u)
                                                              ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                              ⊢ Returning Sort: u
                                                            ⊢ Building closure for La body with environent
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))])
                                                          ▼ inferHeadApp: t^0
                                                            ⊢ HLvl base type successfully fetched fro context.
                                                            ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })]
                                                              ⊢ Returning Sort: 0
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                              ⊢ Appending eli to neutral spine
                                                            ⊢ Successfully applied spine.
                                                    ▼ inferValue @ 0 : VSort (iax(iax(iax((u + 1), u), (0 + 1)), iax(iax(iax((u + 1), iax(iax(u, u), iax(u, u))), 0), 0)))
                                                    ⊢ Coparing two Pis. Checking doain types for: t
                                                    ▼ isDefEqValue @ 0 : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) =?= VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                      ▼ inferValue @ 0 : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u]
                                                            ▼ evalM: Sort(iax((u + 1), u))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u + 1), u)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ evalM: Sort(0)
                                                          ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                          ⊢ Returning Sort: 0
                                                        ▼ inferValue @ 1 : VSort (0)
                                                      ▼ inferValue @ 0 : VSort (iax(iax((u + 1), u), (0 + 1)))
                                                      ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                      ▼ isDefEqValue @ 0 : VDef (TutorialFixture.PN [u] [] <thunk>) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                        ▼ inferValue @ 0 : VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferHeadApp: TutorialFixture.PN[u]
                                                            ▼ evalM: Sort(iax((u + 1), u))
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: iax((u + 1), u)
                                                            ⊢ HConst base type successfully evaluated.
                                                            ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 0 : VSort (iax((u + 1), u))
                                                        ▼ isDefEqSpine @ 0 : [] =?= []
                                                        ⊢ Matched VDefs by head and spine
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                        ⊢ Returning Sort: 0
                                                      ▼ evalM: Sort(0)
                                                        ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^0 [])]
                                                        ⊢ Returning Sort: 0
                                                      ▼ isDefEqValue @ 1 : VSort (0) =?= VSort (0)
                                                        ⊢ Matched via level equivalence
                                                    ▼ evalM: (∀ (v : (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))) , (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))))
                                                      ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                      ⊢ Evaluating Pi doain type: v
                                                      ▼ evalM: (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))
                                                        ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                        ⊢ Evaluating Pi doain type: n
                                                        ▼ evalM: (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Evaluating Pi doain type: α
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ⊢ Building closure for Pi body with environent
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Building closure for Pi body with environent
                                                    ▼ evalM: (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u]))
                                                      ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                      ⊢ Evaluating Pi doain type: v
                                                      ▼ evalM: (∀ (n : TutorialFixture.PN[u]) , (#1 #0))
                                                        ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                        ⊢ Evaluating Pi doain type: n
                                                        ▼ evalM: TutorialFixture.PN[u]
                                                          ⊢ LocalEnv is [VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Building closure for Pi body with environent
                                                      ⊢ Building closure for Pi body with environent
                                                    ▼ isDefEqValue @ 1 : VPi ((v : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))) }) =?= VPi ((v : VPi ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 TutorialFixture.PN.lit2[u]) })
                                                      ▼ inferValue @ 1 : VPi ((v : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))) })
                                                        ▼ inferValue @ 1 : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                          ▼ inferValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VSort (u)
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                            ▼ inferHeadApp: t^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (n^1 []))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                        ▼ evalM: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating La doain type α
                                                            ▼ evalM: Sort(u)
                                                              ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                              ⊢ Returning Sort: u
                                                            ⊢ Building closure for La body with environent
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))])
                                                          ▼ inferHeadApp: t^0
                                                            ⊢ HLvl base type successfully fetched fro context.
                                                            ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })]
                                                              ⊢ Returning Sort: 0
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                              ⊢ Appending eli to neutral spine
                                                            ⊢ Successfully applied spine.
                                                      ▼ inferValue @ 1 : VSort (iax(iax(iax((u + 1), iax(iax(u, u), iax(u, u))), 0), 0))
                                                      ⊢ Coparing two Pis. Checking doain types for: v
                                                      ▼ isDefEqValue @ 1 : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) }) =?= VPi ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                        ▼ inferValue @ 1 : VPi ((n : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })) => Closure{ env: [VNeutral (t^0 [])] body: (#1 #0) })
                                                          ▼ inferValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VSort (u)
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                          ▼ evalM: (#1 #0)
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Evaluating App function
                                                            ▼ evalM: #1
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Evaluating App arguent
                                                            ▼ evalM: #0
                                                              ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                              ⊢ Looking up bound variable
                                                            ⊢ Applying arguent to function
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                              ⊢ Appending eli to neutral spine
                                                          ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                            ▼ inferHeadApp: t^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (n^1 []))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 1 : VSort (iax(iax((u + 1), iax(iax(u, u), iax(u, u))), 0))
                                                        ⊢ Coparing two Pis. Checking doain types for: n
                                                        ▼ isDefEqValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) }) =?= VDef (TutorialFixture.PN [u] [] <thunk>)
                                                          ▼ inferValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VSort (u)
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                  ▼ inferHeadApp: α^1
                                                                    ⊢ HLvl base type successfully fetched fro context.
                                                                    ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 1 : VSort (iax((u + 1), iax(iax(u, u), iax(u, u))))
                                                          ▼ evalM: (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))
                                                            ⊢ LocalEnv is []
                                                            ⊢ Evaluating Pi doain type: α
                                                            ▼ evalM: Sort(u)
                                                              ⊢ LocalEnv is []
                                                              ⊢ Returning Sort: u
                                                            ⊢ Building closure for Pi body with environent
                                                          ▼ isDefEqValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) }) =?= VPi ((α : VSort (u)) => Closure{ env: [] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                            ▼ inferValue @ 1 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                              ▼ inferValue @ 1 : VSort (u)
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: (∀ (a : #0) , #1)
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                                ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                  ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                            ▼ inferValue @ 1 : VSort (iax((u + 1), iax(iax(u, u), iax(u, u))))
                                                            ⊢ Coparing two Pis. Checking doain types for: α
                                                            ▼ isDefEqValue @ 1 : VSort (u) =?= VSort (u)
                                                              ⊢ Matched via level equivalence
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                              ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                              ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                              ▼ evalM: (∀ (a : #0) , #1)
                                                                ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                ⊢ Evaluating Pi doain type: a
                                                                ▼ evalM: #0
                                                                  ⊢ LocalEnv is [VNeutral (α^1 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ⊢ Building closure for Pi body with environent
                                                            ▼ isDefEqValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) }) =?= VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                              ▼ inferValue @ 2 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                                ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                  ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 2 : VSort (iax(iax(u, u), iax(u, u)))
                                                              ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                              ▼ isDefEqValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 }) =?= VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 [])] body: #1 })
                                                                ▼ inferValue @ 2 : VPi ((a : VNeutral (α^1 [])) => Closure{ env: [VNeutral (α^1 []), VNeutral (t^0 [])] body: #1 })
                                                                  ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 2 : VSort (iax(u, u))
                                                                ⊢ Coparing two Pis. Checking doain types for: a
                                                                ▼ isDefEqValue @ 2 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                  ▼ inferValue @ 2 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 2 : VSort (u)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 2 : [] =?= []
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a^2 []), VNeutral (α^1 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ isDefEqValue @ 3 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 3 : VSort (u)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 3 : [] =?= []
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                                ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                ▼ evalM: #1
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                                  ⊢ Looking up bound variable
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ isDefEqValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 }) =?= VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])] body: #2 })
                                                                ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VNeutral (α^1 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ inferValue @ 3 : VSort (iax(u, u))
                                                                ⊢ Coparing two Pis. Checking doain types for: a._@._internal._hyg.0
                                                                ▼ isDefEqValue @ 3 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                  ▼ inferValue @ 3 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 3 : VSort (u)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 3 : [] =?= []
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ evalM: #2
                                                                  ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (a._@._internal._hyg.0^2 []), VNeutral (α^1 [])]
                                                                  ⊢ Looking up bound variable
                                                                ▼ isDefEqValue @ 4 : VNeutral (α^1 []) =?= VNeutral (α^1 [])
                                                                  ▼ inferValue @ 4 : VNeutral (α^1 [])
                                                                    ▼ inferHeadApp: α^1
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ inferValue @ 4 : VSort (u)
                                                                  ⊢ Coparing spines with because heads atch.
                                                                  ▼ isDefEqSpine @ 4 : [] =?= []
                                                        ▼ evalM: (#1 #0)
                                                          ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ evalM: (#1 #0)
                                                          ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating App function
                                                          ▼ evalM: #1
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Evaluating App arguent
                                                          ▼ evalM: #0
                                                            ⊢ LocalEnv is [VNeutral (n^1 []), VNeutral (t^0 [])]
                                                            ⊢ Looking up bound variable
                                                          ⊢ Applying arguent to function
                                                          ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                            ⊢ Appending eli to neutral spine
                                                        ▼ isDefEqValue @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))]) =?= VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                          ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VNeutral (n^1 []))])
                                                            ▼ inferHeadApp: t^0
                                                              ⊢ HLvl base type successfully fetched fro context.
                                                              ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VNeutral (n^1 []))
                                                              ▼ evalM: Sort(0)
                                                                ⊢ LocalEnv is [VNeutral (n^1 [])]
                                                                ⊢ Returning Sort: 0
                                                              ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VNeutral (n^1 []))
                                                                ⊢ Appending eli to neutral spine
                                                              ⊢ Successfully applied spine.
                                                          ▼ inferValue @ 2 : VSort (0)
                                                          ⊢ Coparing spines with because heads atch.
                                                          ▼ isDefEqSpine @ 2 : [EApp (VNeutral (n^1 []))] =?= [EApp (VNeutral (n^1 []))]
                                                            ▼ isDefEqValue @ 2 : VNeutral (n^1 []) =?= VNeutral (n^1 [])
                                                              ▼ inferValue @ 2 : VNeutral (n^1 [])
                                                                ▼ inferHeadApp: n^1
                                                                  ⊢ HLvl base type successfully fetched fro context.
                                                                  ⊢ Successfully applied spine.
                                                              ▼ inferValue @ 2 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)) })
                                                                ▼ inferValue @ 2 : VSort (u)
                                                                ▼ evalM: (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2))
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                  ▼ evalM: (∀ (a : #0) , #1)
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: a
                                                                    ▼ evalM: #0
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 3 : VPi ((a._@._internal._hyg.0 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (t^0 [])] body: (∀ (a._@._internal._hyg.0 : #1) , #2) })
                                                                  ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (t^0 [])] body: #1 })
                                                                    ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                  ▼ evalM: (∀ (a._@._internal._hyg.0 : #1) , #2)
                                                                    ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: a._@._internal._hyg.0
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ inferValue @ 4 : VPi ((a._@._internal._hyg.0 : VNeutral (α^2 [])) => Closure{ env: [VNeutral (a._@._internal._hyg.0^3 []), VNeutral (α^2 []), VNeutral (t^0 [])] body: #2 })
                                                                    ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                    ▼ evalM: #2
                                                                      ⊢ LocalEnv is [VNeutral (a._@._internal._hyg.0^4 []), VNeutral (a._@._internal._hyg.0^3 []), VNeutral (α^2 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                              ⊢ Coparing spines with because heads atch.
                                                              ▼ isDefEqSpine @ 2 : [] =?= []
                                                      ▼ evalM: (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))
                                                        ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))))
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Evaluating La doain type α
                                                          ▼ evalM: Sort(u)
                                                            ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                            ⊢ Returning Sort: u
                                                          ⊢ Building closure for La body with environent
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                          ⊢ Appending eli to neutral spine
                                                      ▼ evalM: (#1 TutorialFixture.PN.lit2[u])
                                                        ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                        ⊢ Evaluating App function
                                                        ▼ evalM: #1
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up bound variable
                                                        ⊢ Evaluating App arguent
                                                        ▼ evalM: TutorialFixture.PN.lit2[u]
                                                          ⊢ LocalEnv is [VNeutral (v^1 []), VNeutral (t^0 [])]
                                                          ⊢ Looking up Const: TutorialFixture.PN.lit2
                                                          ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                        ⊢ Applying arguent to function
                                                        ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VDef (TutorialFixture.PN.lit2 [u] [] <thunk>))
                                                          ⊢ Appending eli to neutral spine
                                                      ▼ isDefEqValue @ 2 : VNeutral (t^0 [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))]) =?= VNeutral (t^0 [EApp (VDef (TutorialFixture.PN.lit2 [u] [] <thunk>))])
                                                        ▼ inferValue @ 2 : VNeutral (t^0 [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))])
                                                          ▼ inferHeadApp: t^0
                                                            ⊢ HLvl base type successfully fetched fro context.
                                                            ⊢ applyTypeEli: VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) }) EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                            ▼ evalM: Sort(0)
                                                              ⊢ LocalEnv is [VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })]
                                                              ⊢ Returning Sort: 0
                                                            ▼ applyEliM @ 2 : VNeutral (t^0 []) ∘ EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))
                                                              ⊢ Appending eli to neutral spine
                                                            ⊢ Successfully applied spine.
                                                        ▼ inferValue @ 2 : VSort (0)
                                                        ⊢ Coparing spines with because heads atch.
                                                        ▼ isDefEqSpine @ 2 : [EApp (VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }))] =?= [EApp (VDef (TutorialFixture.PN.lit2 [u] [] <thunk>))]
                                                          ▼ isDefEqValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }) =?= VDef (TutorialFixture.PN.lit2 [u] [] <thunk>)
                                                            ▼ inferValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })
                                                              ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))
                                                                ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating La doain type s
                                                                ▼ evalM: (∀ (a : #0) , #1)
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ⊢ Building closure for La body with environent
                                                              ▼ inferValue @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) })
                                                                ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                                  ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating La doain type z
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for La body with environent
                                                                ▼ inferValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                                  ▼ evalM: (#1 (#1 #0))
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating App function
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Evaluating App arguent
                                                                    ▼ evalM: (#1 #0)
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: #0
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                        ⊢ Appending eli to neutral spine
                                                                    ⊢ Applying arguent to function
                                                                    ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                      ⊢ Appending eli to neutral spine
                                                                  ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                    ▼ inferHeadApp: s^3
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                        ⊢ Appending eli to neutral spine
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ quote @ 5 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                                ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ quote @ 4 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ quote @ 5 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                              ▼ quote @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                ▼ quote @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                  ▼ quote @ 3 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ quote @ 4 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                                ▼ evalM: (∀ (z : #1) , #2)
                                                                  ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: z
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ quote @ 4 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ quote @ 5 : VNeutral (α^2 [])
                                                                    ⊢ Constructed head expression: α^2
                                                            ▼ inferValue @ 2 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                              ▼ inferValue @ 2 : VSort (u)
                                                              ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                                ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                ⊢ Evaluating Pi doain type: s
                                                                ▼ evalM: (∀ (a : #0) , #1)
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: a
                                                                  ▼ evalM: #0
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ⊢ Building closure for Pi body with environent
                                                              ▼ inferValue @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                  ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                    ▼ inferHeadApp: α^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                    ▼ inferHeadApp: α^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                ▼ evalM: (∀ (z : #1) , #2)
                                                                  ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: z
                                                                  ▼ evalM: #1
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                  ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                    ▼ inferHeadApp: α^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                                  ▼ evalM: #2
                                                                    ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Looking up bound variable
                                                                  ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                    ▼ inferHeadApp: α^2
                                                                      ⊢ HLvl base type successfully fetched fro context.
                                                                      ⊢ Successfully applied spine.
                                                            ▼ evalM: (TutorialFixture.PN.succ[u] TutorialFixture.PN.lit1[u])
                                                              ⊢ LocalEnv is []
                                                              ⊢ Evaluating App function
                                                              ▼ evalM: TutorialFixture.PN.succ[u]
                                                                ⊢ LocalEnv is []
                                                                ⊢ Looking up Const: TutorialFixture.PN.succ
                                                                ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                              ⊢ Evaluating App arguent
                                                              ▼ evalM: TutorialFixture.PN.lit1[u]
                                                                ⊢ LocalEnv is []
                                                                ⊢ Looking up Const: TutorialFixture.PN.lit1
                                                                ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                              ⊢ Applying arguent to function
                                                              ▼ applyEliM @ 0 : VDef (TutorialFixture.PN.succ [u] [] <thunk>) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [] <thunk>))
                                                                ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                            ▼ isDefEqValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }) =?= VDef (TutorialFixture.PN.succ [u] [EApp (VDef (TutorialFixture.PN.lit1 [u] [] <thunk>))] <thunk>)
                                                              ▼ inferValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })
                                                                ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating La doain type s
                                                                  ▼ evalM: (∀ (a : #0) , #1)
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: a
                                                                    ▼ evalM: #0
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ⊢ Building closure for La body with environent
                                                                ▼ inferValue @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) })
                                                                  ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating La doain type z
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for La body with environent
                                                                  ▼ inferValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                                    ▼ evalM: (#1 (#1 #0))
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: (#1 #0)
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: #0
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                          ⊢ Appending eli to neutral spine
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                        ⊢ Appending eli to neutral spine
                                                                    ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                      ▼ inferHeadApp: s^3
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ⊢ Appending eli to neutral spine
                                                                        ⊢ Successfully applied spine.
                                                                    ▼ quote @ 5 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                  ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                    ▼ quote @ 4 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                    ▼ evalM: #2
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ quote @ 5 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                ▼ quote @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                  ▼ quote @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                    ▼ quote @ 3 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ quote @ 4 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                  ▼ evalM: (∀ (z : #1) , #2)
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: z
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                    ▼ quote @ 4 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                                    ▼ evalM: #2
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ quote @ 5 : VNeutral (α^2 [])
                                                                      ⊢ Constructed head expression: α^2
                                                              ▼ inferValue @ 2 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                                ▼ inferValue @ 2 : VSort (u)
                                                                ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating Pi doain type: s
                                                                  ▼ evalM: (∀ (a : #0) , #1)
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: a
                                                                    ▼ evalM: #0
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ⊢ Building closure for Pi body with environent
                                                                ▼ inferValue @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                  ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                    ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                  ▼ evalM: (∀ (z : #1) , #2)
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: z
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ inferValue @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                    ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                                    ▼ evalM: #2
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                      ▼ inferHeadApp: α^2
                                                                        ⊢ HLvl base type successfully fetched fro context.
                                                                        ⊢ Successfully applied spine.
                                                              ▼ evalM: (λ (n : TutorialFixture.PN[u]) => (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))))
                                                                ⊢ LocalEnv is []
                                                                ⊢ Evaluating La doain type n
                                                                ▼ evalM: TutorialFixture.PN[u]
                                                                  ⊢ LocalEnv is []
                                                                  ⊢ Looking up Const: TutorialFixture.PN
                                                                  ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                ⊢ Building closure for La body with environent
                                                              ▼ applyEliM @ 0 : VLa ((n : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))) }) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [] <thunk>))
                                                                ⊢ Beta Reduction: evaluating body with new environent
                                                                ▼ evalM: (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))))
                                                                  ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                  ⊢ Evaluating La doain type α
                                                                  ▼ evalM: Sort(u)
                                                                    ⊢ LocalEnv is [VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Returning Sort: u
                                                                  ⊢ Building closure for La body with environent
                                                              ▼ isDefEqValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) }) =?= VLa ((α : VSort (u)) => Closure{ env: [VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0)))) })
                                                                ▼ inferValue @ 2 : VLa ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0)))) })
                                                                  ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating La doain type s
                                                                    ▼ evalM: (∀ (a : #0) , #1)
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating Pi doain type: a
                                                                      ▼ evalM: #0
                                                                        ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ⊢ Building closure for La body with environent
                                                                  ▼ inferValue @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) })
                                                                    ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating La doain type z
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for La body with environent
                                                                    ▼ inferValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                                      ▼ evalM: (#1 (#1 #0))
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: (#1 #0)
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Evaluating App function
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Evaluating App arguent
                                                                          ▼ evalM: #0
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Applying arguent to function
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                            ⊢ Appending eli to neutral spine
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ⊢ Appending eli to neutral spine
                                                                      ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                        ▼ inferHeadApp: s^3
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                            ⊢ Appending eli to neutral spine
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                    ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ quote @ 4 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                  ▼ quote @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                    ▼ quote @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                      ▼ quote @ 3 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ quote @ 4 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                    ▼ evalM: (∀ (z : #1) , #2)
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating Pi doain type: z
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ quote @ 4 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                ▼ inferValue @ 2 : VPi ((α : VSort (u)) => Closure{ env: [VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2)) })
                                                                  ▼ inferValue @ 2 : VSort (u)
                                                                  ▼ evalM: (∀ (s : (∀ (a : #0) , #1)) , (∀ (z : #1) , #2))
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: s
                                                                    ▼ evalM: (∀ (a : #0) , #1)
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating Pi doain type: a
                                                                      ▼ evalM: #0
                                                                        ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ▼ inferValue @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                    ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                      ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                    ▼ evalM: (∀ (z : #1) , #2)
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating Pi doain type: z
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ▼ inferValue @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                ⊢ Coparing two labdas. Checking doain types for: α
                                                                ▼ isDefEqValue @ 2 : VSort (u) =?= VSort (u)
                                                                  ⊢ Matched via level equivalence
                                                                ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                  ⊢ Evaluating La doain type s
                                                                  ▼ evalM: (∀ (a : #0) , #1)
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating Pi doain type: a
                                                                    ▼ evalM: #0
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ⊢ Building closure for La body with environent
                                                                ▼ evalM: (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (((#3 #2) #1) #0))))
                                                                  ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                  ⊢ Evaluating La doain type s
                                                                  ▼ evalM: (∀ (a : #0) , #1)
                                                                    ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Evaluating Pi doain type: a
                                                                    ▼ evalM: #0
                                                                      ⊢ LocalEnv is [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for Pi body with environent
                                                                  ⊢ Building closure for La body with environent
                                                                ▼ isDefEqValue @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) }) =?= VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: (λ (z : #1) => (#1 (((#3 #2) #1) #0))) })
                                                                  ▼ inferValue @ 3 : VLa ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (λ (z : #1) => (#1 (#1 #0))) })
                                                                    ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating La doain type z
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for La body with environent
                                                                    ▼ inferValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                                      ▼ evalM: (#1 (#1 #0))
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: (#1 #0)
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Evaluating App function
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Evaluating App arguent
                                                                          ▼ evalM: #0
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Applying arguent to function
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                            ⊢ Appending eli to neutral spine
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ⊢ Appending eli to neutral spine
                                                                      ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                        ▼ inferHeadApp: s^3
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                            ⊢ Appending eli to neutral spine
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                    ▼ quote @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ quote @ 4 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                  ▼ inferValue @ 3 : VPi ((s : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (∀ (z : #1) , #2) })
                                                                    ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                      ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                    ▼ evalM: (∀ (z : #1) , #2)
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating Pi doain type: z
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Building closure for Pi body with environent
                                                                    ▼ inferValue @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                  ⊢ Coparing two labdas. Checking doain types for: s
                                                                  ▼ isDefEqValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) =?= VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: #1 })
                                                                    ▼ inferValue @ 3 : VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 })
                                                                      ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                    ▼ inferValue @ 3 : VSort (iax(u, u))
                                                                    ⊢ Coparing two Pis. Checking doain types for: a
                                                                    ▼ isDefEqValue @ 3 : VNeutral (α^2 []) =?= VNeutral (α^2 [])
                                                                      ▼ inferValue @ 3 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ inferValue @ 3 : VSort (u)
                                                                      ⊢ Coparing spines with because heads atch.
                                                                      ▼ isDefEqSpine @ 3 : [] =?= []
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (a^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Looking up bound variable
                                                                    ▼ isDefEqValue @ 4 : VNeutral (α^2 []) =?= VNeutral (α^2 [])
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ inferValue @ 4 : VSort (u)
                                                                      ⊢ Coparing spines with because heads atch.
                                                                      ▼ isDefEqSpine @ 4 : [] =?= []
                                                                  ▼ evalM: (λ (z : #1) => (#1 (#1 #0)))
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                    ⊢ Evaluating La doain type z
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for La body with environent
                                                                  ▼ evalM: (λ (z : #1) => (#1 (((#3 #2) #1) #0)))
                                                                    ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                    ⊢ Evaluating La doain type z
                                                                    ▼ evalM: #1
                                                                      ⊢ LocalEnv is [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Looking up bound variable
                                                                    ⊢ Building closure for La body with environent
                                                                  ▼ isDefEqValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) }) =?= VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)] body: (#1 (((#3 #2) #1) #0)) })
                                                                    ▼ inferValue @ 4 : VLa ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: (#1 (#1 #0)) })
                                                                      ▼ evalM: (#1 (#1 #0))
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: (#1 #0)
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Evaluating App function
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Evaluating App arguent
                                                                          ▼ evalM: #0
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Applying arguent to function
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                            ⊢ Appending eli to neutral spine
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ⊢ Appending eli to neutral spine
                                                                      ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                        ▼ inferHeadApp: s^3
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                            ⊢ Appending eli to neutral spine
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ quote @ 5 : VNeutral (α^2 [])
                                                                        ⊢ Constructed head expression: α^2
                                                                    ▼ inferValue @ 4 : VPi ((z : VNeutral (α^2 [])) => Closure{ env: [VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #2 })
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ evalM: #2
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                    ⊢ Coparing two labdas. Checking doain types for: z
                                                                    ▼ isDefEqValue @ 4 : VNeutral (α^2 []) =?= VNeutral (α^2 [])
                                                                      ▼ inferValue @ 4 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ inferValue @ 4 : VSort (u)
                                                                      ⊢ Coparing spines with because heads atch.
                                                                      ▼ isDefEqSpine @ 4 : [] =?= []
                                                                    ▼ evalM: (#1 (#1 #0))
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: (#1 #0)
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: #1
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: #0
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                          ⊢ Appending eli to neutral spine
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                        ⊢ Appending eli to neutral spine
                                                                    ▼ evalM: (#1 (((#3 #2) #1) #0))
                                                                      ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                      ⊢ Evaluating App function
                                                                      ▼ evalM: #1
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                        ⊢ Looking up bound variable
                                                                      ⊢ Evaluating App arguent
                                                                      ▼ evalM: (((#3 #2) #1) #0)
                                                                        ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                        ⊢ Evaluating App function
                                                                        ▼ evalM: ((#3 #2) #1)
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                          ⊢ Evaluating App function
                                                                          ▼ evalM: (#3 #2)
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                            ⊢ Evaluating App function
                                                                            ▼ evalM: #3
                                                                              ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                              ⊢ Looking up bound variable
                                                                            ⊢ Evaluating App arguent
                                                                            ▼ evalM: #2
                                                                              ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                              ⊢ Looking up bound variable
                                                                            ⊢ Applying arguent to function
                                                                            ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                              ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                          ⊢ Evaluating App arguent
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                            ⊢ Looking up bound variable
                                                                          ⊢ Applying arguent to function
                                                                          ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                        ⊢ Evaluating App arguent
                                                                        ▼ evalM: #0
                                                                          ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (s^3 []), VNeutral (α^2 []), VDef (TutorialFixture.PN.lit1 [u] [] <thunk>)]
                                                                          ⊢ Looking up bound variable
                                                                        ⊢ Applying arguent to function
                                                                        ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                          ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.lit1
                                                                      ⊢ Applying arguent to function
                                                                      ▼ applyEliM @ 4 : VNeutral (s^3 []) ∘ EApp (VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))
                                                                        ⊢ Appending eli to neutral spine
                                                                    ▼ isDefEqValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))]) =?= VNeutral (s^3 [EApp (VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))])
                                                                      ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))])
                                                                        ▼ inferHeadApp: s^3
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                          ▼ evalM: #1
                                                                            ⊢ LocalEnv is [VNeutral (s^3 [EApp (VNeutral (z^4 []))]), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                            ⊢ Looking up bound variable
                                                                          ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))
                                                                            ⊢ Appending eli to neutral spine
                                                                          ⊢ Successfully applied spine.
                                                                      ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                        ▼ inferHeadApp: α^2
                                                                          ⊢ HLvl base type successfully fetched fro context.
                                                                          ⊢ Successfully applied spine.
                                                                      ⊢ Coparing spines with because heads atch.
                                                                      ▼ isDefEqSpine @ 5 : [EApp (VNeutral (s^3 [EApp (VNeutral (z^4 []))]))] =?= [EApp (VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>))]
                                                                        ▼ isDefEqValue @ 5 : VNeutral (s^3 [EApp (VNeutral (z^4 []))]) =?= VDef (TutorialFixture.PN.lit1 [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 []))] <thunk>)
                                                                          ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (z^4 []))])
                                                                            ▼ inferHeadApp: s^3
                                                                              ⊢ HLvl base type successfully fetched fro context.
                                                                              ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (z^4 []))
                                                                              ▼ evalM: #1
                                                                                ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                                ⊢ Looking up bound variable
                                                                              ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                                ⊢ Appending eli to neutral spine
                                                                              ⊢ Successfully applied spine.
                                                                          ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                            ▼ inferHeadApp: α^2
                                                                              ⊢ HLvl base type successfully fetched fro context.
                                                                              ⊢ Successfully applied spine.
                                                                          ▼ evalM: (TutorialFixture.PN.succ[u] TutorialFixture.PN.lit0[u])
                                                                            ⊢ LocalEnv is []
                                                                            ⊢ Evaluating App function
                                                                            ▼ evalM: TutorialFixture.PN.succ[u]
                                                                              ⊢ LocalEnv is []
                                                                              ⊢ Looking up Const: TutorialFixture.PN.succ
                                                                              ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                            ⊢ Evaluating App arguent
                                                                            ▼ evalM: TutorialFixture.PN.lit0[u]
                                                                              ⊢ LocalEnv is []
                                                                              ⊢ Looking up Const: TutorialFixture.PN.lit0
                                                                              ⊢ Const is Defn. Instantiating levels and creating lazy thunk
                                                                            ⊢ Applying arguent to function
                                                                            ▼ applyEliM @ 0 : VDef (TutorialFixture.PN.succ [u] [] <thunk>) ∘ EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))
                                                                              ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                          ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (α^2 []))
                                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                          ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VNeutral (α^2 [])), EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (s^3 []))
                                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                          ▼ applyEliM @ 4 : VDef (TutorialFixture.PN.succ [u] [EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 [])), EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>) ∘ EApp (VNeutral (z^4 []))
                                                                            ⊢ Pushing eli to lazy VDef thunk: TutorialFixture.PN.succ
                                                                          ▼ isDefEqValue @ 5 : VNeutral (s^3 [EApp (VNeutral (z^4 []))]) =?= VDef (TutorialFixture.PN.succ [u] [EApp (VNeutral (z^4 [])), EApp (VNeutral (s^3 [])), EApp (VNeutral (α^2 [])), EApp (VDef (TutorialFixture.PN.lit0 [u] [] <thunk>))] <thunk>)
                                                                            ▼ inferValue @ 5 : VNeutral (s^3 [EApp (VNeutral (z^4 []))])
                                                                              ▼ inferHeadApp: s^3
                                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                                ⊢ applyTypeEli: VPi ((a : VNeutral (α^2 [])) => Closure{ env: [VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])] body: #1 }) EApp (VNeutral (z^4 []))
                                                                                ▼ evalM: #1
                                                                                  ⊢ LocalEnv is [VNeutral (z^4 []), VNeutral (α^2 []), VNeutral (v^1 []), VNeutral (t^0 [])]
                                                                                  ⊢ Looking up bound variable
                                                                                ▼ applyEliM @ 5 : VNeutral (s^3 []) ∘ EApp (VNeutral (z^4 []))
                                                                                  ⊢ Appending eli to neutral spine
                                                                                ⊢ Successfully applied spine.
                                                                            ▼ inferValue @ 5 : VNeutral (α^2 [])
                                                                              ▼ inferHeadApp: α^2
                                                                                ⊢ HLvl base type successfully fetched fro context.
                                                                                ⊢ Successfully applied spine.
                                                                            ⊢ Already unfolding TutorialFixture.PN.succ - skipping and returning False.
                                                  ⊢ Type isatch in declaration body: VPi ((t : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (v : (∀ (n : (∀ (α : Sort(u)) , (∀ (a._@._internal._hyg.0 : (∀ (a : #0) , #1)) , (∀ (a._@._internal._hyg.0 : #1) , #2)))) , (#1 #0))) , (#1 (λ (α : Sort(u)) => (λ (s : (∀ (a : #0) , #1)) => (λ (z : #1) => (#1 (#1 #0))))))) }) vs expected VPi ((t : VPi ((a._@._internal._hyg.0 : VDef (TutorialFixture.PN [u] [] <thunk>)) => Closure{ env: [] body: Sort(0) })) => Closure{ env: [] body: (∀ (v : (∀ (n : TutorialFixture.PN[u]) , (#1 #0))) , (#1 TutorialFixture.PN.lit2[u])) })
                                                  ✗ Type of constant body does not atch declared type: VPi (HCNae {hcnId = 43, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "t"}) Default (VPi (HCNae {hcnId = 8, hcnVal = Nu (HCNae {hcnId = 7, hcnVal = Str (HCNae {hcnId = 6, hcnVal = Str (HCNae {hcnId = 5, hcnVal = Str (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) "_@"}) "_internal"}) "_hyg"}) 0}) Default (VDef (HCNae {hcnId = 32, hcnVal = Str (HCNae {hcnId = 1, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "TutorialFixture"}) "PN"}) [HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})}] [] <thunk>) (Closure {closureEnv = [], closureBody = HCExpr {hceId = 1, hceVal = Sort (HCLevel {hclId = 0, hclVal = LZero})}})) (Closure {closureEnv = [], closureBody = HCExpr {hceId = -28, hceVal = ForallE (HCNae {hcnId = 44, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "v"}) (HCExpr {hceId = -27, hceVal = ForallE (HCNae {hcnId = 35, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "n"}) (HCExpr {hceId = -12, hceVal = ForallE (HCNae {hcnId = 18, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "\945"}) (HCExpr {hceId = 15, hceVal = Sort (HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})})}) (HCExpr {hceId = 51, hceVal = ForallE (HCNae {hcnId = 8, hcnVal = Nu (HCNae {hcnId = 7, hcnVal = Str (HCNae {hcnId = 6, hcnVal = Str (HCNae {hcnId = 5, hcnVal = Str (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) "_@"}) "_internal"}) "_hyg"}) 0}) (HCExpr {hceId = 16, hceVal = ForallE (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) (HCExpr {hceId = 3, hceVal = BVar 0}) (HCExpr {hceId = 7, hceVal = BVar 1}) Default}) (HCExpr {hceId = 50, hceVal = ForallE (HCNae {hcnId = 8, hcnVal = Nu (HCNae {hcnId = 7, hcnVal = Str (HCNae {hcnId = 6, hcnVal = Str (HCNae {hcnId = 5, hcnVal = Str (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) "_@"}) "_internal"}) "_hyg"}) 0}) (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 49, hceVal = BVar 2}) Default}) Default}) Default}) (HCExpr {hceId = 38, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 3, hceVal = BVar 0})}) Default}) (HCExpr {hceId = -26, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = -25, hceVal = La (HCNae {hcnId = 18, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "\945"}) (HCExpr {hceId = 15, hceVal = Sort (HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})})}) (HCExpr {hceId = -24, hceVal = La (HCNae {hcnId = 36, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "s"}) (HCExpr {hceId = 16, hceVal = ForallE (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) (HCExpr {hceId = 3, hceVal = BVar 0}) (HCExpr {hceId = 7, hceVal = BVar 1}) Default}) (HCExpr {hceId = -23, hceVal = La (HCNae {hcnId = 37, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "z"}) (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = -22, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 38, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 3, hceVal = BVar 0})})}) Default}) Default}) Default})}) Default}}) vs VPi (HCNae {hcnId = 43, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "t"}) Default (VPi (HCNae {hcnId = 8, hcnVal = Nu (HCNae {hcnId = 7, hcnVal = Str (HCNae {hcnId = 6, hcnVal = Str (HCNae {hcnId = 5, hcnVal = Str (HCNae {hcnId = 4, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "a"}) "_@"}) "_internal"}) "_hyg"}) 0}) Default (VDef (HCNae {hcnId = 32, hcnVal = Str (HCNae {hcnId = 1, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "TutorialFixture"}) "PN"}) [HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})}] [] <thunk>) (Closure {closureEnv = [], closureBody = HCExpr {hceId = 1, hceVal = Sort (HCLevel {hclId = 0, hclVal = LZero})}})) (Closure {closureEnv = [], closureBody = HCExpr {hceId = 78, hceVal = ForallE (HCNae {hcnId = 44, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "v"}) (HCExpr {hceId = 75, hceVal = ForallE (HCNae {hcnId = 35, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "n"}) (HCExpr {hceId = 73, hceVal = Const (HCNae {hcnId = 32, hcnVal = Str (HCNae {hcnId = 1, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "TutorialFixture"}) "PN"}) [HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})}]}) (HCExpr {hceId = 38, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 3, hceVal = BVar 0})}) Default}) (HCExpr {hceId = 77, hceVal = App (HCExpr {hceId = 7, hceVal = BVar 1}) (HCExpr {hceId = 76, hceVal = Const (HCNae {hcnId = 41, hcnVal = Str (HCNae {hcnId = 32, hcnVal = Str (HCNae {hcnId = 1, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "TutorialFixture"}) "PN"}) "lit2"}) [HCLevel {hclId = 2, hclVal = LVar (HCNae {hcnId = 17, hcnVal = Str (HCNae {hcnId = 0, hcnVal = Anonyous}) "u"})}]})}) Default}})
==============================================
