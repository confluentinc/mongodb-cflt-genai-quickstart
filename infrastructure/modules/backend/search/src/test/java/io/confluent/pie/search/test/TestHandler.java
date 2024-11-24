package io.confluent.pie.search.test;

import io.confluent.kafka.serializers.json.KafkaJsonSchemaDeserializerConfig;
import io.confluent.kafka.serializers.json.KafkaJsonSchemaSerializer;
import io.confluent.pie.search.SearchHandler;
import io.confluent.pie.search.models.Credentials;
import io.confluent.pie.search.models.KafkaEvent;
import io.confluent.pie.search.models.LambdaKafkaEvent;
import io.confluent.pie.search.models.SearchRequest;
import io.confluent.pie.search.models.SearchResults;
import io.confluent.pie.search.services.SearchRequestDeserializerConfiguration;
import io.confluent.pie.search.services.SearchRequestDeserializerSupplier;
import io.confluent.pie.search.services.impl.MongoService;
import io.confluent.pie.search.tools.ConfigUtils;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.junit.jupiter.api.Assertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Disabled;
import org.junit.jupiter.api.Test;
import org.testcontainers.kafka.KafkaContainer;

import java.io.IOException;
import java.time.Duration;
import java.util.ArrayList;
import java.util.Base64;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import static org.apache.kafka.clients.consumer.ConsumerConfig.*;

@Disabled
public class TestHandler {

    public static KafkaContainer kafka = new KafkaContainer("apache/kafka-native:3.8.0");

    @BeforeAll
    public static void setup() {
        kafka.start();
    }

    @Test
    public void testOnMessage() throws IOException {
        final LambdaKafkaEvent lambdaKafkaEvent = getKafkaEvent();

        final SearchHandler handler = new SearchHandler(
                () -> new MongoService(
                        new Credentials(System.getenv("MONGO_USERNAME"), System.getenv("MONGO_PASSWORD")),
                        System.getenv("MONGO_HOST"),
                        "genai",
                        "all_insurance_products_embeddings",
                        "vector_index",
                        "embeddings"),
                () -> {
                    try {
                        return new KafkaProducer<>(ConfigUtils.loadConfig(
                                kafka.getBootstrapServers(),
                                null,
                                "mock://",
                                null));
                    } catch (IOException e) {
                        throw new RuntimeException(e);
                    }
                },
                new SearchRequestDeserializerSupplier(
                        new SearchRequestDeserializerConfiguration("mock://",
                                null)),
                "search_results"
        );

        Assertions.assertTrue(handler.handleRequest(lambdaKafkaEvent, null));

        // Consume events
        try (KafkaConsumer<String, SearchResults> consumer = new KafkaConsumer<>(getConsumerProperties())) {
            consumer.subscribe(Collections.singletonList("search_results"));

            final List<SearchResults> results = new ArrayList<>();
            while (results.isEmpty()) {
                consumer.poll(Duration.ofMillis(1000)).forEach(record -> results.add(record.value()));
            }

            Assertions.assertEquals(1, results.size());
            Assertions.assertEquals("abc", results.get(0).requestId());
            Assertions.assertEquals(1, results.get(0).results().length);
        }
    }

    private Properties getConsumerProperties() {
        return new Properties() {{
            // User-specific properties that you must set
            put(BOOTSTRAP_SERVERS_CONFIG, kafka.getBootstrapServers());
            put(KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getCanonicalName());
            put(VALUE_DESERIALIZER_CLASS_CONFIG, SearchResultsDeserializer.class.getCanonicalName());
            put(GROUP_ID_CONFIG, "test-group");
            put(AUTO_OFFSET_RESET_CONFIG, "earliest");
            put(KafkaJsonSchemaDeserializerConfig.SCHEMA_REGISTRY_URL_CONFIG, "mock://");
            put(KafkaJsonSchemaDeserializerConfig.JSON_VALUE_TYPE, SearchResults.class.getName());
        }};
    }

    private LambdaKafkaEvent getKafkaEvent() {
        final KafkaEvent kafkaEvent = new KafkaEvent(
                "topic-0",
                0,
                0,
                0,
                "CREATE_TIME",
                Base64.getEncoder().encodeToString("key".getBytes()),
                Base64.getEncoder().encodeToString(getSearchRequest()),
                List.of(new HashMap<>() {{
                    put("header-0", new byte[]{0});
                }})
        );

        final Map<String, List<KafkaEvent>> records = new HashMap<>();
        records.put("topic-0", List.of(kafkaEvent));

        return new LambdaKafkaEvent(
                "abc",
                "locakhost:9092",
                records
        );
    }

    private byte[] getSearchRequest() {
        final SearchRequest searchRequest = new SearchRequest(
                "abc",
                new double[]{-0.011935698799788952, 0.024386607110500336, 0.011592225171625614, -0.027993077412247658, -0.01803234964609146, 0.0020823071245104074, 0.009960726834833622, -0.059420887380838394, 0.017946481704711914, -0.0019535047467797995, 0.009059109725058079, -0.004636890254914761, 0.04568195343017578, -0.033145178109407425, -0.0014382946537807584, 0.05014710873365402, -0.04430806264281273, 0.02035079523921013, -0.016830194741487503, 0.006182520184665918, -0.025760501623153687, 0.01751714013516903, 0.015370432287454605, 0.04207548499107361, -0.006182520184665918, 0.02507355436682701, -0.02060840092599392, -0.05186447501182556, 0.0001086771153495647, -0.02988218143582344, -0.004465153440833092, -0.013910670764744282, -0.015112827531993389, 0.025245290249586105, 0.007814018987119198, 0.03280170261859894, 0.029710443690419197, 0.04121680185198784, 0.03761032968759537, 0.05976436287164688, -0.06354256719350815, -0.037095122039318085, -0.001207523513585329, -0.014511749148368835, 0.015456300228834152, 0.08312054723501205, 0.008543899282813072, 0.014340012334287167, 0.015628037974238396, 0.001148488954640925, -0.03331691399216652, 0.0076852161437273026, -0.010561805218458176, 0.014855221845209599, -0.03812554106116295, 0.04842974245548248, 0.021295348182320595, -0.028680024668574333, -0.04035811871290207, -0.016830194741487503, -0.04121680185198784, -0.06010783463716507, 0.0006252288003452122, -0.008930306881666183, 0.0014490281464532018, 0.012450908310711384, -0.0006681630038656294, -0.019921453669667244, -0.020522532984614372, -0.03589296340942383, -0.031084338203072548, 0.011420488357543945, -0.032629966735839844, -0.019835585728287697, -0.02627571113407612, -0.034003861248493195, 0.001084087765775621, -0.00515210023149848, 0.015971509739756584, 0.010905278846621513, -0.01296611875295639, 0.021295348182320595, -0.009144977666437626, -0.057703521102666855, 0.005409704986959696, -0.035721227526664734, 0.03280170261859894, -0.005581441801041365, 0.006311322562396526, 0.02035079523921013, 0.012794381938874722, -0.03589296340942383, 0.012622645124793053, 0.008672702126204967, -0.02507355436682701, -0.0008372162701562047, -0.05529920756816864, -0.007170006167143583, -0.0875857025384903, 0.027993077412247658, -0.011248752474784851, -0.02318445034325123, -0.056329626590013504, 0.015284563414752483, 0.018547561019659042, 0.04568195343017578, 0.000009978839443647303, -0.037953805178403854, 0.041045065969228745, 0.027821341529488564, -0.007814018987119198, -0.0009767523733898997, 0.04602542892098427, -0.05220794677734375, 0.014597617089748383, -0.005280902609229088, 0.04568195343017578, 0.014340012334287167, 0.0338321253657341, -0.008071623742580414, 0.0091879116371274, -0.015112827531993389, 0.027821341529488564, -0.012021566741168499, 0.009531385265290737, -0.0014168275520205498, 0.011077015660703182, 0.00100358622148633, 0.019577980041503906, 0.051177527755498886, 0.021896425634622574, 0.022669240832328796, -0.003864075057208538, 0.0024901817087084055, -0.016314983367919922, -0.08071623742580414, -0.05839046835899353, 0.017603008076548576, -0.04946016147732735, -0.033145178109407425, 0.02902349829673767, -0.06422951817512512, 0.03726685792207718, 0.017946481704711914, -0.017946481704711914, 0.02232576720416546, -0.014425880275666714, -0.0036064700689166784, 0.0024901817087084055, 0.023356188088655472, 0.013309592381119728, 0.028680024668574333, 0.0011216551065444946, 0.06354256719350815, 0.032629966735839844, 0.024730080738663673, -0.005839047022163868, 0.021552952006459236, 0.008286294527351856, -0.02000732161104679, -0.020179059356451035, 0.001100188004784286, -0.025245290249586105, 0.02318445034325123, -0.08552486449480057, -0.030053917318582535, 0.012365040369331837, 0.00013416926958598197, -0.020436663180589676, 0.013051986694335938, 0.030053917318582535, 0.06182520091533661, 0.03898422420024872, 0.04310590401291847, 0.010518871247768402, -0.0012236237525939941, 0.02112361043691635, -0.011592225171625614, -0.013223723508417606, -0.03726685792207718, 0.027821341529488564, -0.06835119426250458, -0.010647674091160297, 0.04602542892098427, 0.07178592681884766, 0.012193303555250168, -0.01296611875295639, -0.06938161700963974, 0.015112827531993389, 0.01579977385699749, -0.03589296340942383, -0.05873394012451172, 0.020951874554157257, 0.004830094054341316, 0.051177527755498886, -0.03417559713125229, -0.013481329195201397, 0.03761032968759537, 0.05255142226815224, 0.060451310127973557, -0.04396458715200424, -0.004164614249020815, -0.013910670764744282, 0.040186382830142975, 0.07796844840049744, -0.018805164843797684, -0.02000732161104679, 0.04430806264281273, -0.05255142226815224, -0.005924914963543415, 0.01803234964609146, 0.0069982693530619144, 0.005323837045580149, -0.04310590401291847, 0.030053917318582535, -0.030912600457668304, -0.009960726834833622, -0.021810557693243027, -0.015026958659291267, -0.056329626590013504, 0.016314983367919922, 0.02000732161104679, -0.0676642507314682, -0.006483059376478195, 0.06148172914981842, 0.005001830402761698, 0.016143247485160828, -0.020951874554157257, -0.037953805178403854, 0.02232576720416546, -0.010475937277078629, 0.028680024668574333, -0.036579910665750504, 0.03417559713125229, -0.03761032968759537, 0.006440125405788422, 0.02902349829673767, -0.0069982693530619144, 0.0029409904964268208, -0.03692338615655899, 0.034003861248493195, -0.07384677231311798, 0.0030053916852921247, -0.01099114678800106, -0.005538507830351591, 0.009488451294600964, 0.018547561019659042, -0.05873394012451172, -0.009703122079372406, -0.015284563414752483, 0.08861612528562546, 0.0704120323061943, -0.0338321253657341, -0.0422472208738327, -0.0006091285031288862, -0.0009982193587347865, -0.0535818412899971, -0.02627571113407612, 0.03159954771399498, -0.02318445034325123, -0.0735032930970192, -0.027821341529488564, 0.05392531678080559, -0.03434733301401138, -0.003348865080624819, 0.07865539938211441, -0.02318445034325123, 0.0005903448327444494, 0.014082406647503376, 0.005667310208082199, -0.0735032930970192, 0.004164614249020815, -0.017946481704711914, 0.00691240094602108, -0.0009713855688460171, 0.02060840092599392, 0.0367516465485096, 0.02318445034325123, -0.002983924699947238, 0.028680024668574333, -0.030569126829504967, -0.012794381938874722, -0.028336551040410995, 0.05323836952447891, 0.017688877880573273, 0.034003861248493195, 0.005710244178771973, -0.054612260311841965, -0.04396458715200424, 0.0028336551040410995, -0.021552952006459236, 0.01605737954378128, 0.01227917242795229, -0.001663699047639966, -0.054268788546323776, 0.05873394012451172, 0.027821341529488564, -0.016486721113324165, -0.026103973388671875, 0.023012714460492134, 0.007513479329645634, 0.008458031341433525, -0.0033703322988003492, -0.04173200950026512, -0.03812554106116295, 0.0034776676911860704, -0.009660188108682632, -0.004336351063102484, -0.02369965985417366, -0.013309592381119728, -0.004121680278331041, 0.010561805218458176, 0.005710244178771973, -0.037095122039318085, -0.04842974245548248, -0.08346401900053024, -0.022154031321406364, -0.0007191473268903792, 0.007298808544874191, -0.025588763877749443, -0.024730080738663673, 0.0011323887156322598, 0.035377755761146545, 0.013653065077960491, -0.034862544387578964, -0.07247287780046463, -0.026447447016835213, 0.02284097671508789, -0.04173200950026512, 0.010690608061850071, -0.027821341529488564, -0.04430806264281273, -0.01468348503112793, -0.04121680185198784, -0.008715636096894741, 0.0007781817694194615, -0.022669240832328796, -0.039327699691057205, -0.025588763877749443, 0.02541702799499035, -0.002200376009568572, 0.0067406645976006985, 0.05873394012451172, -0.029195234179496765, 0.02507355436682701, 0.022497504949569702, 0.02988218143582344, -0.0054741064086556435, -0.026619184762239456, 0.03503428027033806, -0.0010196864604949951, -0.04602542892098427, -0.015026958659291267, -0.010819409973919392, 0.020093191415071487, 0.012193303555250168, 0.09067696332931519, -0.04602542892098427, -0.038812488317489624, -0.026103973388671875, 0.057703521102666855, -0.020951874554157257, 0.003413266269490123, 0.001491962349973619, -0.01691606268286705, 0.015284563414752483, 0.055986154824495316, 0.04911668971180916, -0.007942820899188519, -0.010475937277078629, 0.011077015660703182, 0.039327699691057205, 0.0367516465485096, -0.03778206929564476, 0.0007030470296740532, -0.0018032350344583392, 0.0044866204261779785, 0.005044764839112759, 0.010690608061850071, -0.001695899642072618, 0.010905278846621513, -0.01803234964609146, -0.02988218143582344, 0.011678094044327736, -0.0022647774312645197, -0.04774279519915581, -0.04173200950026512, -0.030912600457668304, 0.008844438940286636, 0.02902349829673767, -0.011935698799788952, -0.014340012334287167, -0.011334620416164398, -0.004744225647300482, -0.033145178109407425, -0.006182520184665918, 0.03915596008300781, 0.016572589054703712, -0.016830194741487503, 0.027993077412247658, -0.0007567147258669138, 0.021638819947838783, 0.019663849845528603, -0.033660389482975006, 0.05564268305897713, -0.01210743561387062, -0.0025545828975737095, 0.033660389482975006, -0.06938161700963974, 0.01691606268286705, 0.020179059356451035, 0.001932037528604269, 0.001996438717469573, -0.014340012334287167, -0.05255142226815224, -0.00957431923598051, 0.0033703322988003492, -0.048086266964673996, 0.03331691399216652, 0.0004991096793673933, -0.005581441801041365, -0.011678094044327736, 0.014425880275666714, -0.023871397599577904, 0.014597617089748383, 0.027821341529488564, -0.003026858903467655, -0.015885641798377037, 0.00901617482304573, -0.011678094044327736, 0.005409704986959696, -0.0016422319458797574, -0.022669240832328796, -0.03211475908756256, -0.004164614249020815, 0.012536777183413506, -0.01665845699608326, -0.013567197136580944, -0.05804699659347534, 0.037095122039318085, 0.0067406645976006985, 0.0016314983367919922, -0.05152100324630737, -0.040186382830142975, 0.007084137760102749, 0.01296611875295639, -0.014425880275666714, 0.05392531678080559, 0.010475937277078629, 0.06594688445329666, -0.009531385265290737, 0.006182520184665918, -0.019406244158744812, 0.01751714013516903, -0.0018247021362185478, 0.010261266492307186, 0.01116288360208273, -0.04035811871290207, -0.01313785556703806, -0.0075564137659966946, 0.02369965985417366, 0.08380749821662903, 0.02369965985417366, -0.001996438717469573, -0.04705584794282913, -0.021037742495536804, -0.0027907209005206823, 0.03520601615309715, 0.07831192016601562, -0.040186382830142975, -0.014597617089748383, 0.005967849399894476, -0.006826532538980246, -0.06594688445329666, -0.023356188088655472, -0.042762432247400284, -0.023012714460492134, 0.08071623742580414, 0.006783598568290472, 0.008200425654649734, -0.00605371780693531, 0.02764960378408432, 0.0037138054613023996, -0.008672702126204967, -0.033145178109407425, 0.012193303555250168, -0.013309592381119728, 0.027821341529488564, 0.017688877880573273, 0.07006856054067612, -0.041045065969228745, 0.024901816621422768, 0.030912600457668304, -0.0035850030835717916, -0.03864075243473053, 0.04070159047842026, 0.024730080738663673, -0.036579910665750504, 0.016143247485160828, 0.0025975171010941267, 0.04911668971180916, 0.004980363417416811, -0.04465153440833092, -0.00048569278442300856, -0.05014710873365402, -0.035721227526664734, 0.03211475908756256, -0.009660188108682632, 0.017860613763332367, -0.009059109725058079, -0.02902349829673767, 0.04310590401291847, -0.061138253659009933, 0.043277639895677567, -0.002200376009568572, -0.005924914963543415, 0.01210743561387062, 0.037095122039318085, 0.05186447501182556, 0.0075564137659966946, 0.0004534921608865261, -0.002232576720416546, 0.04636890068650246, 0.012193303555250168, 0.007212940137833357, -0.028680024668574333, -0.036236438900232315, 0.00832922849804163, 0.025245290249586105, 0.006182520184665918, -0.005710244178771973, -0.0762510821223259, -0.03812554106116295, -0.007041203323751688, 0.01579977385699749, -0.04602542892098427, 0.033145178109407425, -0.05323836952447891, -0.042762432247400284, -0.01691606268286705, 0.025760501623153687, -0.02764960378408432, 0.015456300228834152, -0.007513479329645634, -0.008071623742580414, -0.010475937277078629, 0.0025653166230767965, -0.007084137760102749, 0.007041203323751688, 0.0704120323061943, 0.02318445034325123, -0.04396458715200424, 0.04070159047842026, -0.003907009493559599, 0.02369965985417366, 0.034003861248493195, -0.06148172914981842, 0.03864075243473053, -0.014855221845209599, 0.043277639895677567, 0.051177527755498886, 0.06182520091533661, -0.018805164843797684, 0.03726685792207718, -0.0008211159729398787, -0.029710443690419197, 0.08655527979135513, 0.028680024668574333, -0.006139586213976145, -0.026103973388671875, 0.0183758232742548, -0.010003660805523396, -0.023527923971414566, 0.0058819809928536415, 0.010046595707535744, -0.004958896432071924, 0.026962658390402794, -0.05220794677734375, 0.042762432247400284, 0.024043133482336998, -0.035721227526664734, 0.003971410449594259, -0.019921453669667244, -0.018118219450116158, 0.04156027361750603, -0.04602542892098427, -0.005323837045580149, -0.0023506456054747105, 0.04911668971180916, -0.054612260311841965, 0.05392531678080559, 0.05049058049917221, 0.060451310127973557, 0.021295348182320595, 0.010948212817311287, 0.002415047027170658, -0.01296611875295639, -0.04035811871290207, 0.06422951817512512, 0.02507355436682701, -0.020436663180589676, -0.01751714013516903, -0.0075564137659966946, 0.010003660805523396, -0.031084338203072548, -0.039671171456575394, -0.009960726834833622, 0.015370432287454605, 0.07247287780046463, 0.008586833253502846, -0.014511749148368835, -0.010046595707535744, 0.04739931970834732, 0.021638819947838783, -0.062168676406145096, -0.011678094044327736, 0.01803234964609146, 0.035721227526664734, 0.0011216551065444946, 0.0026941190008074045, -0.0422472208738327, -0.015112827531993389, -0.007814018987119198, 0.010218331590294838, -0.02541702799499035, -0.027306130155920982, 0.06251215189695358, 0.00020796238095499575, 0.013910670764744282, -0.022669240832328796, 0.03417559713125229, 0.028336551040410995, -0.03417559713125229, 0.011592225171625614, 0.002983924699947238, -0.03761032968759537, -0.001100188004784286, 0.046712376177310944, -0.0024579812306910753, 0.012622645124793053, -0.028164813295006752, -0.016314983367919922, -0.033660389482975006, -0.048086266964673996, 0.07831192016601562, -0.009917792864143848, 0.004915962461382151, 0.025760501623153687, 0.007513479329645634, 0.04156027361750603, -0.02318445034325123, 0.013051986694335938, -0.02455834485590458, 0.020436663180589676, 0.03812554106116295, 0.01313785556703806, -0.04070159047842026, -0.027306130155920982, 0.019406244158744812, 0.013481329195201397, -0.003048325888812542, -0.05873394012451172, -0.0057531786151230335, 0.0003864075115416199, 0.013309592381119728, -0.013051986694335938, 0.027134394273161888, 0.018547561019659042, 0.005924914963543415, 0.02000732161104679, -0.03692338615655899, 0.02318445034325123, 0.04774279519915581, 0.02421487122774124, 0.015971509739756584, -0.02764960378408432, -0.04946016147732735, 0.026619184762239456, 0.005109165795147419, 0.01803234964609146, 0.03915596008300781, 0.003391799284145236, 0.04310590401291847, 0.024730080738663673, -0.008071623742580414, 0.0027907209005206823, -0.028680024668574333, 0.00691240094602108, -0.030225655063986778, 0.0034776676911860704, -0.05152100324630737, -0.04430806264281273, 0.02764960378408432, -0.006654796190559864, -0.008801504038274288, -0.022154031321406364, -0.008672702126204967, 0.003155661281198263, 0.019835585728287697, -0.007298808544874191, -0.032629966735839844, 0.02455834485590458, 0.0075564137659966946, 0.04774279519915581, -0.00015899058780632913, 0.005538507830351591, 0.038812488317489624, -0.011077015660703182, -0.056329626590013504, 0.022669240832328796, -0.017345404252409935, 0.013051986694335938, 0.05186447501182556, -0.004636890254914761, 0.0030053916852921247, 0.022154031321406364, -0.06835119426250458, 0.015370432287454605, -0.012536777183413506, 0.04842974245548248, 0.04877321422100067, 0.027134394273161888, 0.021896425634622574, 0.055986154824495316, -0.007814018987119198, -0.07075551152229309, 0.009788990020751953, 0.007771084550768137, 0.007212940137833357, -0.02086600475013256, -0.04173200950026512, 0.003284463891759515, -0.017345404252409935, -0.01949211210012436, -0.007728150114417076, -0.0735032930970192, -0.04842974245548248, 0.09273780137300491, 0.04774279519915581, 0.01184982992708683, -0.00032871472649276257, 0.012536777183413506, 0.02627571113407612, 0.024386607110500336, 0.012708513997495174, 0.006697730161249638, 0.030225655063986778, -0.007642281707376242, -0.008844438940286636, 0.0030697931069880724, -0.006354256998747587, 0.014597617089748383, 0.016314983367919922, 0.03159954771399498, 0.025245290249586105, 0.010561805218458176, -0.031084338203072548, -0.00020930406753905118, -0.006268388591706753, 0.013996538706123829, 0.031771283596754074, -0.02902349829673767, -0.001867636339738965, -0.03211475908756256, 0.009703122079372406, -0.004572488833218813, 0.010475937277078629, 0.004379285033792257, 0.046712376177310944, 0.033145178109407425, -0.01313785556703806, -0.012794381938874722, -0.0009016175172291696, -0.003026858903467655, -0.013051986694335938, 0.05529920756816864, 0.020179059356451035, -0.02000732161104679, -0.035377755761146545, 0.04946016147732735, 0.03984290733933449, -0.0028336551040410995, 0.00957431923598051, 0.016572589054703712, -0.0035850030835717916, -0.0013953604502603412, 0.015370432287454605, -0.03761032968759537, -0.01914863847196102, -0.000007882445061113685, 0.011506357230246067, 0.057703521102666855, 0.011678094044327736, -0.027306130155920982, 0.007942820899188519, -0.04035811871290207, -0.03280170261859894, 0.0012504576006904244, 0.06182520091533661, 0.027993077412247658, 0.0183758232742548, -0.03692338615655899, 0.03761032968759537, -0.02421487122774124, -0.029710443690419197, -0.005323837045580149, -0.021037742495536804, 0.051177527755498886, -0.01382480189204216, -0.02593223750591278, -0.013567197136580944, -0.02764960378408432, 0.03297344222664833, -0.011248752474784851, -0.005796112585812807, 0.0007245140732266009, -0.020093191415071487, 0.008801504038274288, 0.035721227526664734, 0.04207548499107361, -0.015628037974238396, -0.03211475908756256, 0.0007406143704429269, 0.09823337942361832, -0.013395460322499275, 0.03331691399216652, -0.004658357240259647, -0.001663699047639966, -0.04465153440833092, -0.011420488357543945, -0.00024150469107553363, 0.021638819947838783, -0.04173200950026512, 0.0367516465485096, 0.03503428027033806, 0.027134394273161888, -0.03434733301401138, -0.008071623742580414, 0.041903749108314514, -0.06525993347167969, 0.030912600457668304, 0.017946481704711914, -0.0005876614013686776, -0.015542169101536274, 0.015456300228834152, 0.02627571113407612, 0.03761032968759537, 0.012622645124793053, 0.008157491683959961, -0.006397190969437361, -0.011420488357543945, 0.009831924922764301, 0.06525993347167969, -0.024901816621422768, -0.007341742515563965, 0.005710244178771973, 0.041903749108314514, -0.02318445034325123, -0.005023297853767872, 0.004830094054341316, -0.005710244178771973, 0.0036064700689166784, 0.0676642507314682, 0.0367516465485096, -0.0036064700689166784, 0.008500965312123299, 0.0004159247619099915, 0.0067406645976006985, -0.007814018987119198, -0.030569126829504967, 0.034003861248493195, -0.034003861248493195, 0.05014710873365402, 0.06422951817512512, 0.04877321422100067, -0.06388603895902634, -0.043277639895677567, 0.03864075243473053, 0.019663849845528603, -0.012021566741168499, -0.04156027361750603, -0.02421487122774124, -0.011592225171625614, -0.054268788546323776, -0.009144977666437626, 0.020522532984614372, 0.020522532984614372, 0.013051986694335938, -0.003348865080624819, 0.0025653166230767965, 0.00027102194144390523, -0.0003421316505409777, 0.04602542892098427, 0.017688877880573273, 0.05255142226815224, -0.006182520184665918, 0.007084137760102749, -0.030569126829504967, 0.026962658390402794, 0.027306130155920982, 0.02318445034325123, 0.046712376177310944, -0.006182520184665918, 0.015284563414752483, -0.03864075243473053, 0.02902349829673767, -0.017001930624246597, 0.07728150486946106, 0.018461693078279495, 0.011592225171625614, -0.035721227526664734, 0.03194301947951317, 0.014168275520205498, 0.0006547460798174143, 0.017087798565626144, -0.008930306881666183, -0.03778206929564476, -0.05976436287164688, -0.005130633246153593, -0.026962658390402794, 0.016314983367919922, -0.016486721113324165, -0.01579977385699749, -0.001524162944406271, -0.005044764839112759, 0.016830194741487503, -0.008672702126204967, 0.00974605605006218, 0.023356188088655472, -0.015971509739756584, -0.009703122079372406, -0.05220794677734375, -0.046712376177310944, 0.007427610922604799, 0.02764960378408432, -0.00691240094602108, 0.0025975171010941267, 0.00023882130335550755, 0.055986154824495316, -0.02627571113407612, 0.04877321422100067, 0.024386607110500336, -0.003026858903467655, 0.022154031321406364, -0.0019535047467797995, 0.007212940137833357, 0.009059109725058079, -0.010690608061850071, -0.010475937277078629, -0.001524162944406271, -0.03829727694392204, 0.013395460322499275, -0.023356188088655472, -0.04842974245548248, 0.014511749148368835, 0.04533848166465759, -0.04842974245548248, 0.03331691399216652, -0.015456300228834152, -0.01296611875295639, 0.013996538706123829, -0.023356188088655472, -0.004293416626751423, -0.04430806264281273, 0.059420887380838394, -0.027821341529488564, 0.016572589054703712, 0.03984290733933449, 0.04739931970834732, 0.00747054535895586, -0.023871397599577904, 0.0009660187643021345, 0.003627937287092209, -0.0076852161437273026, 0.007642281707376242, -0.011420488357543945, -0.021638819947838783, -0.009788990020751953, -0.032629966735839844, 0.004915962461382151, -0.019663849845528603, 0.024730080738663673, -0.03761032968759537, 0.006955335382372141, -0.025760501623153687, 0.08071623742580414, -0.026619184762239456, 0.02593223750591278, 0.02627571113407612, 0.02060840092599392, 0.03520601615309715, 0.005796112585812807, -0.07831192016601562, 0.02679092064499855, 0.013051986694335938, 0.057360049337148666, -0.021552952006459236, 0.10235505551099777, -0.03434733301401138, 0.028164813295006752, 0.00691240094602108, 0.013481329195201397, -0.022154031321406364, 0.023356188088655472, -0.048086266964673996, 0.027993077412247658, -0.015370432287454605, 0.0054741064086556435, -0.07522065937519073, 0.031771283596754074, -0.026619184762239456, -0.031084338203072548, -0.039671171456575394, -0.011763961985707283, 0.022154031321406364, -0.006955335382372141, -0.022497504949569702, -0.04774279519915581, -0.04877321422100067, -0.03864075243473053, -0.02936697006225586, 0.028164813295006752, -0.004744225647300482, -0.020436663180589676},
                10,
                10,
                0.99,
                Map.of("key", "value"));

        final Map<String, Object> config = new HashMap<>();
        config.put("schema.registry.url", "mock://");

        try (KafkaJsonSchemaSerializer<SearchRequest> kafkaJsonSchemaSerializer = new KafkaJsonSchemaSerializer<>()) {
            kafkaJsonSchemaSerializer.configure(config, false);

            return kafkaJsonSchemaSerializer.serialize("topic", searchRequest);
        }
    }
}