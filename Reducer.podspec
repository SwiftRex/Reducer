Pod::Spec.new do |s|
  s.name             = 'Reducer'
  s.version          = '0.9.0'
  s.summary          = 'SwiftRex Reducer'
  s.description      = <<-DESC
                        SwiftRex Reducer is a component of SwiftRex.
                        SwiftRex is a framework that combines event-sourcing pattern and reactive programming (Combine, RxSwift or ReactiveSwift), providing a central state Store of which your ViewControllers or SwiftUI Views can observe and react to, as well as dispatching events coming from the user interaction.
                        This pattern is also known as 'Unidirectional Dataflow' or 'Redux'.
                        DESC
  s.homepage         = 'https://github.com/SwiftRex/Reducer'
  s.license          = { :type => 'Apache 2.0', :file => 'LICENSE' }
  s.author           = { 'Luiz Barbosa' => 'swiftrex@developercity.de' }
  s.source           = { :git => 'https://github.com/SwiftRex/Reducer.git',
                         :tag => s.version }

  s.requires_arc     = true

  s.frameworks       = 'Foundation'

  s.ios.deployment_target       = '11.0'
  s.osx.deployment_target       = '10.13'
  s.watchos.deployment_target   = '4.0'
  s.tvos.deployment_target      = '11.0'
  s.swift_version               = '5.7'

  s.source_files  = "Sources/Reducer/**/*.swift"
  s.framework  = "Foundation"
end