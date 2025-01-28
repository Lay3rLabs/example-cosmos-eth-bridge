import 'justfiles/vars.just'
import 'justfiles/build.just'
import 'justfiles/deploy.just'
import 'justfiles/bridge.just'
import 'justfiles/backend.just'

help:
  just --list

clean:
  @rm -rf .build-artifacts
  @rm -rf .wavs-data
  @rm -rf cache 
  @rm -rf out
  @rm -rf cache
  @rm -rf broadcast