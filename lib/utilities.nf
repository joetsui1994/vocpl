@Grab('org.yaml:snakeyaml:1.17')
import org.yaml.snakeyaml.Yaml
include { display_version } from './messages'

// print help messages or pipeline version number if prompted
def help_or_version(String version) {
    // show version number
    if (params.version) {
        display_version(version)
        System.exit(0)
    }
}

// merge global (or default) params with run-specific params
def merge_params(Map map_left, Map map_right) {
    return map_right.inject(map_left.clone()) { map, entry ->
        if (map[entry.key] instanceof Map && entry.value instanceof Map) {
            map[entry.key] = merge_params(map[entry.key], entry.value)
        } else {
            map[entry.key] = entry.value
        }
        return map
    }
}

// read pre-specified seeds from file
def read_seeds(String seeds_tab) {
    seeds = new File(seeds_tab).text.readLines()
    all_ints = seeds
        .findAll { it.isInteger() & (it as BigInteger) < Integer.MAX_VALUE }
        .collect { it as Integer }
    return all_ints
}

// make seeds
def make_seeds(int num) {
    Random random = new Random()
    seeds = [];
    for (i=0; i<num; i++) {
        seeds.add(random.nextInt() & Integer.MAX_VALUE)
    }
    return seeds
}