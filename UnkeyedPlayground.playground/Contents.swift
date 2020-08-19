import UIKit
import Foundation

// add new case
// add new metatype mapping
// add new effect type and define type
// when implementing usage, you can switch case wrapped.effect.type and case from the wrapped by `let item : DistortionEffect = wrapped.cast()`

// type
enum EffectType : String, Codable {
    case reverb
    case distortion
    case mixed
    case page
    
    var metatype: Effect.Type {
        switch self {
        case .reverb:
            return ReverbEffect.self
        case .distortion:
            return DistortionEffect.self
        case .mixed:
            return MixedEffect.self
        case .page:
            return Page.self
        }
    }
}


// effects
protocol Effect: Codable {
    var type: EffectType { get }
}

struct ReverbEffect: Effect {
    let type = EffectType.reverb
    let data : String
}

struct DistortionEffect: Effect {
    let type = EffectType.distortion
    let data : Int
}

struct MixedEffect: Effect {
    let type = EffectType.mixed
    let data : [String]
    let reverb : ReverbEffect
}

struct Page : Effect {
    let type = EffectType.page
    let title : String
    let reverb : ReverbEffect
    let distortion : DistortionEffect
}

// wrapper (doesnt need to be touched)
struct EffectWrapper {
    var effect: Effect?
    func cast<T>() -> T? where T : Effect {
        return effect as? T
    }
}
extension EffectWrapper: Codable {
    private enum CodingKeys: CodingKey {
        case type
    }
    init(from decoder: Decoder) throws {
        guard let container = try? decoder.container(keyedBy: CodingKeys.self) else { return }
        guard let type = try? container.decode(EffectType.self, forKey: .type) else { return }
        self.effect = try? type.metatype.init(from: decoder)
    }
    func encode(to encoder: Encoder) throws {
        try effect?.encode(to: encoder)
    }
}


let sampleReverb = ReverbEffect(data: "hi")
let sampleDistortion = DistortionEffect(data: 4)
let samplePage = Page(title: "super cool page", reverb: .init(data: "super cool reverb"), distortion: .init(data: 69))
let effectsChain: [Effect] = [sampleDistortion, sampleReverb, samplePage]

do {
    
    // Encoding
    let wrappedChain: [EffectWrapper] = effectsChain.map{EffectWrapper(effect:$0)}

    let encoder = JSONEncoder()
    encoder.outputFormatting = .prettyPrinted

    let jsonData = try encoder.encode(wrappedChain)
    let jsonString = String(data: jsonData, encoding: .utf8)
    if let json = jsonString {
        print("json:\n\(json)")
    }

    // Decoding
    let rawData = """
    [
      {
        "type" : "distortion",
        "data" : 2
      },
      {
        "type" : "reverb",
        "data" : "hello there"
      },
      {
        "type" : "other",
        "data" : "hello there"
      },
      {
        "data" : "hello there"
      },
      {
        "type" : "reverb",
        "data" : "i hate sand"
      },
      {
        "type" : "mixed",
        "data" : [ "hello", "there"],
        "reverb" : {
          "type" : "reverb",
          "data" : "mixed i hate sand"
        }
      }
    ]
    """.data(using: .utf8)!
    
    func pageHandler(_ item: Page) {
        print("found page \(item.title)")
        print("\(item.reverb)")
        print("\(item.distortion)")
    }
    func mixedHandler(_ item: MixedEffect) {
        print("found mixed \(item.reverb.data)")
        print("\(item.data)")
    }
    func reverbHandler(_ item: ReverbEffect) {
        print("found reverb \(item.data)")
    }
    func distortionHandler(_ item: DistortionEffect) {
        print("found distortion \(item.data)")
    }
    
    let newChain = try JSONDecoder().decode([EffectWrapper].self, from:rawData)
    print("We restored the chain: %@", newChain)
    newChain.forEach { (wrapped) in
        switch wrapped.effect?.type {
        case .distortion:
            guard let item : DistortionEffect = wrapped.cast() else {break}
            distortionHandler(item)
            break
        case .reverb:
            guard let item : ReverbEffect = wrapped.cast() else {break}
            reverbHandler(item)
            break
        case .mixed:
            guard let item : MixedEffect = wrapped.cast() else {break}
            mixedHandler(item)
            break
        case .page:
            guard let item : Page = wrapped.cast() else {break}
            pageHandler(item)
            break
        case .none:
            print("couldnt deserialize one")
            break
        default:
            break
        }
    }
    
    let pageRawData = """
    {
        "type" : "page",
        "title":"my special page",
        "distortion": {
          "type" : "distortion",
          "data" : 2
        },
        "reverb" : {
          "type" : "reverb",
          "data" : "mixed i hate sand"
        }
    }
    """.data(using: .utf8)!

    let effect = try JSONDecoder().decode(EffectWrapper.self, from: pageRawData)
    print("We restored the chain: %@", effect)
    switch effect.effect?.type {
    case .page:
        guard let item : Page = effect.cast() else {break}
        pageHandler(item)
        break
    case .none:
        print("couldnt deserialize one")
        break
    default:
        break
    }

} catch  {
    print(error)
}
