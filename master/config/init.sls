# This state is responsible for laying down all the formulas and configuration used by the master.
# On initial install this state should be called using the following command
#    salt-call --local state.apply master.config
include:
  - master.config.formulas
  - master.config.pillar
  - master.config.state
  - master.config.masterd
