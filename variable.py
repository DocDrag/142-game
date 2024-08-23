import pygame
import colors
import get_image
import get_audio
import framework as fw
import randomGacha as gacha

class Variable():
    def __init__(self, pygame: pygame):
        # ตัวแปรใช้ทั่วไป
        self.user_name = "admin"
        self.clock = pygame.time.Clock()
        self.FPS = 60
        # Colors
        self.colors = colors.Colors()
        # ตัวแปรของเพลง
        self.audio_volume_music = 10
        self.audio_volume_efx = 10
        self.audio_background_music = pygame.mixer.Sound(get_audio.debirun_sound)
        self.audio_gacha_efx = pygame.mixer.Sound(get_audio.gacha_sound)
        self.set_audio_volume()
        self.audio_background_music.play(-1)
        # ตัวแปรของปุ่ม
        self.btnBack = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnBack)
        # ภาพพื้นหลัง
        self.bg_gem = fw.ImageText('', 0, (0, 0, 0), get_image.bg_gem)
        self.bg_text_area = fw.ImageText('', 25, (0, 0, 0), get_image.bg_text_area)
        self.bg_vsMons01 = pygame.image.load(get_image.bg_vsMons01)
        
        self.init_page_paly_variables()
        self.init_page_play_card_variables()
        self.init_page_main_variables()
        self.init_page_setting_variables()
        self.init_page_gacha_variables()

        # set ค่าเริ่มต้น
        self.set_start()

    def init_page_main_variables(self):
        # ตัวแปรหน้า page_main
        # ตัวแปรข้อความ
        self.text_name_game = fw.Text('142 Game', 50, self.colors.BLACK)
        self.text_version = fw.Text('', 30, self.colors.BLACK)
        # ตัวแปรของปุ่ม
        self.btnPlay = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnPlay)
        self.btnGacha = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnGacha)
        self.btnSetting = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnSetting)
        self.btnExit = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnExit)
        self.btnPrevious = fw.Button('<', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnNext = fw.Button('>', 20, self.colors.WHITE, self.colors.DARK_BLUE)

    def init_page_paly_variables(self):
        # ตัวแปรหน้า page_play
        self.btnPlayCard = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnPlayCard)
        self.btnPlayAns = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnPlayAns)
        self.btnPlayVsMons = fw.ImageButton('', 0, self.colors.WHITE, get_image.btnPlayVsMons)

    def init_page_play_card_variables(self):
        # ตัวแปรหน้า page_play_card
        # ตัวแปรของรูป
        card_image_paths = [get_image.c_ami, get_image.c_ashy, get_image.c_bu, get_image.c_del, get_image.c_mild, get_image.c_suru]
        back_image_path = get_image.back_card
        self.card_images = [pygame.image.load(img).convert_alpha() for img in card_image_paths]
        self.back_image = pygame.image.load(back_image_path).convert_alpha()

    def init_page_setting_variables(self):
        # ตัวแปรหน้า page_setting
        # ตัวแปรของปุ่ม
        self.btnReduce_1_music = fw.Button('-1', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnIncrease_1_music = fw.Button('+1', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnReduce_10_music = fw.Button('-10', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnIncrease_10_music = fw.Button('+10', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnReduce_1_efx = fw.Button('-1', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnIncrease_1_efx = fw.Button('+1', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnReduce_10_efx = fw.Button('-10', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        self.btnIncrease_10_efx = fw.Button('+10', 20, self.colors.WHITE, self.colors.DARK_BLUE)
        # ตัวแปรของ dropdown
        self.dropdownScreen = fw.Dropdown(['Full Screen', '1920x1080', '1280x720', '854x480'], 24, self.colors.WHITE, self.colors.DARK_BLUE)

    def init_page_gacha_variables(self):
        # ตัวแปรหน้า page_gacha
        # ชื่อของ banner ที่จะใช้สุ่ม
        self.banner_gacha_name = 'Rate-Up Debirun'
        # ตัวแปรข้อความ
        self.result1 = ''
        self.result2 = f'กดเพื่อสุ่มตู้ {self.banner_gacha_name} ได้เลย!!!'
        self.result3 = ''
        self.result4 = ''
        self.result5 = ''
        # ตัวแปรของปุ่ม
        options = []
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_AMI, name_button='Rate-Up Beta AMI'))
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_Ashyra, name_button='Rate-Up T-Reina Ashyra'))
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_Debirun, name_button='Rate-Up Debirun'))
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_MildR, name_button='Rate-Up Mild-R'))
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_Tsururu, name_button='Rate-Up Kumoku Tsururu'))
        options.append(fw.ImageButton('', 0, self.colors.WHITE, get_image.banner_Xonebu, name_button='Rate-Up Xonebu X’thulhu'))
        self.scroll_gacha = fw.ScrollableMenu(options, True, False, 4)
        self.btn_1roll = fw.Button('สุ่ม 142 gem', 20, self.colors.WHITE, self.colors.GREEN)
        self.btn_10roll = fw.Button('สุ่ม 1420 gem', 20, self.colors.WHITE, self.colors.GREEN)

    def set_audio_volume(self):
        # audio_music
        audio_volume_music = self.audio_volume_music / 100
        self.audio_background_music.set_volume(audio_volume_music)
        # audio_efx
        audio_volume_efx = self.audio_volume_efx / 100
        self.audio_gacha_efx.set_volume(audio_volume_efx)

    def volume_up_music(self, key):
        self.audio_volume_music = min(100, self.audio_volume_music + key)
        self.set_audio_volume()

    def volume_up_efx(self, key):
        self.audio_volume_efx = min(100, self.audio_volume_efx + key)
        self.set_audio_volume()

    def volume_down_music(self, key):
        self.audio_volume_music = max(0, self.audio_volume_music - key)
        self.set_audio_volume()

    def volume_down_efx(self, key):
        self.audio_volume_efx = max(0, self.audio_volume_efx - key)
        self.set_audio_volume()

    def show_gem(self, screen: fw.Screen, pack_x: int = 540, pack_y: int = 20, width: int = 75, height: int = 15):
        gacha_calculator = gacha.GachaCalculator(self.user_name)
        x = screen.pack_x(pack_x)
        y = screen.pack_y(pack_y)
        width = screen.width(width)
        gem_scale = screen.width(height * 2)
        height = screen.height(height)
        self.bg_text_area.show(screen.window, x, y, width, height, f'{format(gacha_calculator.get_user_gem(self.user_name), ",")}', center_mode=True)
        self.bg_gem.show(screen.window, (x-(gem_scale-(gem_scale//8))), (y - (height//2)), gem_scale, gem_scale)

    def set_start(self):
        self.all_sprites = pygame.sprite.Group()
